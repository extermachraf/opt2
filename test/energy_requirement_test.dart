import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivita/services/profile_service.dart';

void main() {
  group('computeEnergyRequirement — BMI boundary & gender tests', () {
    // ── Case A: Underweight boundary (BMI ≤ 18.5 → factor 1.5) ──────────
    test('A) female, 53.46 kg, 1.70 m, age 25 → BMI ≈ 18.50, factor 1.5', () {
      final r = ProfileService.computeEnergyRequirement(
        weightKg: 53.46,
        heightM: 1.70,
        ageYears: 25,
        gender: 'female',
      );

      final bmi = r['bmi'] as double;
      expect(bmi, closeTo(18.50, 0.01));
      expect(r['bmi_class'], 'underweight');
      expect(r['correction_factor'], 1.5);
      expect(r['weight_used'], 53.46); // not obese → entered weight

      // Female BMR: 655.095 + 9.5634*53.46 + 1.849*1.70 - 4.6756*25
      final expectedBmr = 655.095 + (9.5634 * 53.46) + (1.849 * 1.70) - (4.6756 * 25);
      expect(r['bmr'] as double, closeTo(expectedBmr, 0.1));
      expect(r['total_energy'] as double, closeTo(expectedBmr * 1.5, 0.1));
    });

    // ── Case B: Just above underweight (BMI > 18.5 → factor 1.3) ────────
    test('B) female, 53.50 kg, 1.70 m, age 25 → BMI ≈ 18.51, factor 1.3', () {
      final r = ProfileService.computeEnergyRequirement(
        weightKg: 53.50,
        heightM: 1.70,
        ageYears: 25,
        gender: 'female',
      );

      final bmi = r['bmi'] as double;
      expect(bmi, greaterThan(18.5));
      expect(r['bmi_class'], 'normal_overweight');
      expect(r['correction_factor'], 1.3);
      expect(r['weight_used'], 53.50);

      final expectedBmr = 655.095 + (9.5634 * 53.50) + (1.849 * 1.70) - (4.6756 * 25);
      expect(r['bmr'] as double, closeTo(expectedBmr, 0.1));
      expect(r['total_energy'] as double, closeTo(expectedBmr * 1.3, 0.1));
    });

    // ── Case C: Normal/overweight upper boundary (BMI ≤ 29.9 → factor 1.3)
    // Note: 86.411 / 1.70² = 29.900000000000002 (IEEE 754 overflow → obese).
    // Use 86.40 kg to stay clearly within normal_overweight.
    test('C) male, 86.40 kg, 1.70 m, age 30 → BMI ≈ 29.896, factor 1.3, weight_used = entered', () {
      final r = ProfileService.computeEnergyRequirement(
        weightKg: 86.40,
        heightM: 1.70,
        ageYears: 30,
        gender: 'male',
      );

      final bmi = r['bmi'] as double;
      expect(bmi, closeTo(29.896, 0.01));
      expect(bmi, lessThanOrEqualTo(29.9));
      expect(r['bmi_class'], 'normal_overweight');
      expect(r['correction_factor'], 1.3);
      expect(r['weight_used'], 86.40); // not obese → entered weight

      // Male BMR: 66.4730 + 13.7156*86.40 + 5.033*1.70 - 6.755*30
      final expectedBmr = 66.4730 + (13.7156 * 86.40) + (5.033 * 1.70) - (6.755 * 30);
      expect(r['bmr'] as double, closeTo(expectedBmr, 0.1));
      expect(r['total_energy'] as double, closeTo(expectedBmr * 1.3, 0.1));
    });

    // ── Case D: Obese (BMI > 29.9 → factor 1.2, reference weight) ───────
    test('D) male, 86.50 kg, 1.70 m, age 30 → BMI > 29.9, factor 1.2, weight_used = reference', () {
      final r = ProfileService.computeEnergyRequirement(
        weightKg: 86.50,
        heightM: 1.70,
        ageYears: 30,
        gender: 'male',
      );

      final bmi = r['bmi'] as double;
      expect(bmi, greaterThan(29.9));
      expect(r['bmi_class'], 'obese');
      expect(r['correction_factor'], 1.2);

      // Reference weight = (weight * 0.25) + (heightM^2 * 22)
      final refWeight = (86.50 * 0.25) + (1.70 * 1.70 * 22);
      expect(r['weight_used'] as double, closeTo(refWeight, 0.01));

      // Male BMR with reference weight
      final expectedBmr = 66.4730 + (13.7156 * refWeight) + (5.033 * 1.70) - (6.755 * 30);
      expect(r['bmr'] as double, closeTo(expectedBmr, 0.1));
      expect(r['total_energy'] as double, closeTo(expectedBmr * 1.2, 0.1));
    });

    // ── Gender branch: same inputs, male vs female give different BMR ────
    test('Male vs female with identical inputs produce different BMR', () {
      final male = ProfileService.computeEnergyRequirement(
        weightKg: 70.0, heightM: 1.75, ageYears: 30, gender: 'male',
      );
      final female = ProfileService.computeEnergyRequirement(
        weightKg: 70.0, heightM: 1.75, ageYears: 30, gender: 'female',
      );

      expect(male['bmr'] as double, isNot(closeTo(female['bmr'] as double, 1.0)));
      // Female base constant (655) is much higher but male weight coeff (13.7) is higher
      // For 70 kg: male BMR ≈ 66+960+9-203 = 832; female BMR ≈ 655+669+3-140 = 1187
      expect((female['bmr'] as double), greaterThan(male['bmr'] as double));
    });
  });
}

