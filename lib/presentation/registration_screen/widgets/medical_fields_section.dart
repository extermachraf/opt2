import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MedicalFieldsSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController phoneController;
  final TextEditingController birthPlaceController;
  final TextEditingController fiscalCodeController;
  final TextEditingController residenceController;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;

  const MedicalFieldsSection({
    Key? key,
    required this.nameController,
    required this.surnameController,
    required this.phoneController,
    required this.birthPlaceController,
    required this.fiscalCodeController,
    required this.residenceController,
    required this.selectedGender,
    required this.onGenderChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informazioni Aggiuntive',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Questi campi sono facoltativi ma aiutano a personalizzare la tua esperienza',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textMediumEmphasisLight,
          ),
        ),
        SizedBox(height: 3.h),

        // Genere alla nascita Field - MOVED FROM REQUIRED SECTION
        DropdownButtonFormField<String>(
          value: selectedGender,
          decoration: InputDecoration(
            labelText: 'Genere alla nascita',
            hintText: 'Seleziona genere',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Maschio')),
            DropdownMenuItem(value: 'female', child: Text('Femmina')),
            DropdownMenuItem(value: 'other', child: Text('Altro')),
            DropdownMenuItem(
              value: 'prefer_not_to_say',
              child: Text('Preferisco non specificare'),
            ),
          ],
          onChanged: onGenderChanged,
        ),

        SizedBox(height: 3.h),

        // Nome Field
        TextFormField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Nome',
            hintText: 'Il tuo nome',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Cognome Field
        TextFormField(
          controller: surnameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Cognome',
            hintText: 'Il tuo cognome',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Telefono Field
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Numero di telefono',
            hintText: '+39 123 456 7890',
            prefixIcon: Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Luogo di nascita Field
        TextFormField(
          controller: birthPlaceController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Luogo di nascita',
            hintText: 'Città di nascita',
            prefixIcon: Icon(Icons.location_city_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Codice Fiscale Field
        TextFormField(
          controller: fiscalCodeController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 16,
          decoration: InputDecoration(
            labelText: 'Codice Fiscale',
            hintText: 'RSSMRA80A01H501Z',
            prefixIcon: Icon(Icons.credit_card_outlined),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
            ),
          ),
          onChanged: (value) {
            // Auto-uppercase as user types
            if (value != value.toUpperCase()) {
              fiscalCodeController.value = fiscalCodeController.value.copyWith(
                text: value.toUpperCase(),
                selection: TextSelection.collapsed(offset: value.length),
              );
            }
          },
        ),

        SizedBox(height: 3.h),

        // Comune di residenza Field
        TextFormField(
          controller: residenceController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Comune di residenza',
            hintText: 'Il tuo comune di residenza',
            prefixIcon: Icon(Icons.home_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // Info Card
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Tutti questi campi sono facoltativi. Puoi compilarli ora o aggiungerli successivamente nel tuo profilo.',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
