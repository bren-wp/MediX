import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_page.dart';

class ClinicalToolsScreen extends StatelessWidget {
  const ClinicalToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      safeArea: false,
      appBar: AppBar(title: const Text('Klinički alati')),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          const MedixSectionCard(
            accent: MedixColors.cyan,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedixIconBubble(
                  icon: Icons.calculate_outlined,
                  color: MedixColors.cyan,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Brzi kalkulatori i bodovni sustavi za profesionalni rad. Rezultat je pomoćni izračun i mora se tumačiti u kliničkom kontekstu.',
                    style: TextStyle(
                      color: MedixColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._definitions.map(
            (tool) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: MedixSectionCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _CalculatorScreen(tool: tool),
                  ),
                ),
                child: Row(
                  children: [
                    MedixIconBubble(
                      icon: tool.icon,
                      color: tool.color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tool.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tool.subtitle,
                            style: const TextStyle(
                              color: MedixColors.textSecondary,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: MedixColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalculatorScreen extends StatefulWidget {
  const _CalculatorScreen({required this.tool});

  final _ToolDefinition tool;

  @override
  State<_CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<_CalculatorScreen> {
  late final Map<String, Object?> values;
  _ToolResult? result;
  String? error;

  @override
  void initState() {
    super.initState();
    values = <String, Object?>{
      for (final field in widget.tool.fields) field.id: field.initialValue,
    };
  }

  void _calculate() {
    try {
      final next = widget.tool.calculate(values);
      setState(() {
        result = next;
        error = null;
      });
    } on FormatException catch (exception) {
      setState(() {
        result = null;
        error = exception.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      safeArea: false,
      appBar: AppBar(title: Text(widget.tool.title)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          MedixSectionCard(
            accent: widget.tool.color,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedixIconBubble(
                  icon: widget.tool.icon,
                  color: widget.tool.color,
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.tool.description,
                    style: const TextStyle(
                      color: MedixColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...widget.tool.fields.map(_fieldWidget),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate_rounded),
            label: const Text('Izračunaj'),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            MedixSectionCard(
              accent: MedixColors.danger,
              child: Text(
                error!,
                style: const TextStyle(color: MedixColors.danger),
              ),
            ),
          ],
          if (result != null) ...[
            const SizedBox(height: 12),
            MedixSectionCard(
              accent: widget.tool.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rezultat',
                    style: TextStyle(
                      color: MedixColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    result!.value,
                    style: TextStyle(
                      color: widget.tool.color,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result!.detail,
                    style: const TextStyle(
                      color: MedixColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Rezultat nije samostalna dijagnoza ni terapijska preporuka.',
                    style: TextStyle(
                      color: MedixColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fieldWidget(_ToolField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: switch (field.type) {
        _FieldType.number => TextFormField(
            initialValue: field.initialValue?.toString() ?? '',
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: field.label,
              suffixText: field.unit,
            ),
            onChanged: (value) {
              values[field.id] = double.tryParse(
                value.replaceAll(',', '.').trim(),
              );
            },
          ),
        _FieldType.toggle => SwitchListTile.adaptive(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 4),
            title: Text(field.label),
            subtitle: field.help == null
                ? null
                : Text(
                    field.help!,
                    style: const TextStyle(
                      color: MedixColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
            value: values[field.id] == true,
            onChanged: (value) {
              setState(() => values[field.id] = value);
            },
          ),
        _FieldType.choice => DropdownButtonFormField<int>(
            initialValue: values[field.id] as int?,
            decoration: InputDecoration(labelText: field.label),
            items: field.options
                .map(
                  (option) => DropdownMenuItem<int>(
                    value: option.value,
                    child: Text(option.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() => values[field.id] = value);
            },
          ),
      },
    );
  }
}

enum _FieldType { number, toggle, choice }

class _ChoiceOption {
  const _ChoiceOption(this.value, this.label);

  final int value;
  final String label;
}

class _ToolField {
  const _ToolField.number(
    this.id,
    this.label, {
    this.unit,
    this.initialValue,
  })  : type = _FieldType.number,
        help = null,
        options = const [];

  const _ToolField.toggle(
    this.id,
    this.label, {
    this.help,
    this.initialValue = false,
  })  : type = _FieldType.toggle,
        unit = null,
        options = const [];

  const _ToolField.choice(
    this.id,
    this.label,
    this.options, {
    this.initialValue,
  })  : type = _FieldType.choice,
        unit = null,
        help = null;

  final String id;
  final String label;
  final _FieldType type;
  final String? unit;
  final String? help;
  final Object? initialValue;
  final List<_ChoiceOption> options;
}

class _ToolResult {
  const _ToolResult(this.value, this.detail);

  final String value;
  final String detail;
}

typedef _Calculator = _ToolResult Function(Map<String, Object?> values);

class _ToolDefinition {
  const _ToolDefinition({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.fields,
    required this.calculate,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<_ToolField> fields;
  final _Calculator calculate;
}

double _number(Map<String, Object?> values, String id, String label) {
  final value = values[id];
  if (value is num && value.isFinite && value > 0) {
    return value.toDouble();
  }
  throw FormatException('Unesite valjanu vrijednost za: $label.');
}

bool _flag(Map<String, Object?> values, String id) => values[id] == true;

int _choice(Map<String, Object?> values, String id, String label) {
  final value = values[id];
  if (value is int) return value;
  throw FormatException('Odaberite vrijednost za: $label.');
}

final List<_ToolDefinition> _definitions = [
  _ToolDefinition(
    title: 'BMI',
    subtitle: 'Indeks tjelesne mase',
    description:
        'Izračun indeksa tjelesne mase iz tjelesne mase i visine.',
    icon: Icons.monitor_weight_outlined,
    color: MedixColors.cyan,
    fields: const [
      _ToolField.number('weight', 'Tjelesna masa', unit: 'kg'),
      _ToolField.number('height', 'Visina', unit: 'cm'),
    ],
    calculate: (values) {
      final weight = _number(values, 'weight', 'tjelesna masa');
      final heightCm = _number(values, 'height', 'visina');
      final height = heightCm / 100;
      final bmi = weight / (height * height);
      return _ToolResult(
        bmi.toStringAsFixed(1),
        'BMI = masa / visina².',
      );
    },
  ),
  _ToolDefinition(
    title: 'BSA',
    subtitle: 'Tjelesna površina · Mosteller',
    description:
        'Procjena tjelesne površine prema Mostellerovoj formuli.',
    icon: Icons.accessibility_new_rounded,
    color: MedixColors.primary,
    fields: const [
      _ToolField.number('weight', 'Tjelesna masa', unit: 'kg'),
      _ToolField.number('height', 'Visina', unit: 'cm'),
    ],
    calculate: (values) {
      final weight = _number(values, 'weight', 'tjelesna masa');
      final height = _number(values, 'height', 'visina');
      final bsa = math.sqrt((height * weight) / 3600);
      return _ToolResult(
        '${bsa.toStringAsFixed(2)} m²',
        'Mosteller: √((visina × masa) / 3600).',
      );
    },
  ),
  _ToolDefinition(
    title: 'eGFR · MDRD',
    subtitle: 'Procijenjena glomerularna filtracija',
    description:
        'MDRD IDMS procjena iz dobi, serumskog kreatinina i spola. Ne uključuje zastarjeli rasni koeficijent.',
    icon: Icons.water_drop_outlined,
    color: MedixColors.purple,
    fields: const [
      _ToolField.number('age', 'Dob', unit: 'god.'),
      _ToolField.number(
        'creatinine',
        'Serumski kreatinin',
        unit: 'mg/dL',
      ),
      _ToolField.choice(
        'sex',
        'Spol',
        [
          _ChoiceOption(0, 'Muški'),
          _ChoiceOption(1, 'Ženski'),
        ],
        initialValue: 0,
      ),
    ],
    calculate: (values) {
      final age = _number(values, 'age', 'dob');
      final creatinine =
          _number(values, 'creatinine', 'serumski kreatinin');
      final sex = _choice(values, 'sex', 'spol');

      var egfr = 175 *
          math.pow(creatinine, -1.154) *
          math.pow(age, -0.203);
      if (sex == 1) egfr *= 0.742;

      return _ToolResult(
        '${egfr.toStringAsFixed(0)} mL/min/1,73 m²',
        'Procjena prema MDRD IDMS formuli.',
      );
    },
  ),
  _ToolDefinition(
    title: 'CHA₂DS₂-VASc',
    subtitle: 'Bodovni sustav za AF',
    description:
        'Izračun bodova iz standardnih CHA₂DS₂-VASc čimbenika.',
    icon: Icons.favorite_border_rounded,
    color: MedixColors.danger,
    fields: const [
      _ToolField.number('age', 'Dob', unit: 'god.'),
      _ToolField.toggle('chf', 'Srčano zatajenje'),
      _ToolField.toggle('htn', 'Hipertenzija'),
      _ToolField.toggle('dm', 'Dijabetes'),
      _ToolField.toggle('stroke', 'Moždani udar / TIA / embolija'),
      _ToolField.toggle('vascular', 'Vaskularna bolest'),
      _ToolField.toggle('female', 'Ženski spol'),
    ],
    calculate: (values) {
      final age = _number(values, 'age', 'dob');
      var score = 0;
      if (_flag(values, 'chf')) score += 1;
      if (_flag(values, 'htn')) score += 1;
      if (age >= 75) {
        score += 2;
      } else if (age >= 65) {
        score += 1;
      }
      if (_flag(values, 'dm')) score += 1;
      if (_flag(values, 'stroke')) score += 2;
      if (_flag(values, 'vascular')) score += 1;
      if (_flag(values, 'female')) score += 1;
      return _ToolResult(
        '$score bodova',
        'Prikazan je zbroj standardnih CHA₂DS₂-VASc čimbenika.',
      );
    },
  ),
  _ToolDefinition(
    title: 'HAS-BLED',
    subtitle: 'Bodovi za rizik krvarenja',
    description:
        'Zbroj standardnih HAS-BLED čimbenika za strukturiranu procjenu.',
    icon: Icons.bloodtype_outlined,
    color: MedixColors.danger,
    fields: const [
      _ToolField.toggle('htn', 'Hipertenzija'),
      _ToolField.toggle('renal', 'Abnormalna bubrežna funkcija'),
      _ToolField.toggle('liver', 'Abnormalna jetrena funkcija'),
      _ToolField.toggle('stroke', 'Prethodni moždani udar'),
      _ToolField.toggle('bleeding', 'Krvarenje / predispozicija'),
      _ToolField.toggle('inr', 'Labilan INR'),
      _ToolField.toggle('age65', 'Dob > 65 godina'),
      _ToolField.toggle('drugs', 'Lijekovi koji povećavaju rizik'),
      _ToolField.toggle('alcohol', 'Alkohol'),
    ],
    calculate: (values) {
      const ids = [
        'htn',
        'renal',
        'liver',
        'stroke',
        'bleeding',
        'inr',
        'age65',
        'drugs',
        'alcohol',
      ];
      final score = ids.where((id) => _flag(values, id)).length;
      return _ToolResult(
        '$score bodova',
        'Zbroj označenih HAS-BLED čimbenika.',
      );
    },
  ),
  _ToolDefinition(
    title: 'GCS',
    subtitle: 'Glasgowska ljestvica kome',
    description:
        'Zbroj odgovora otvaranja očiju, verbalnog i motoričkog odgovora.',
    icon: Icons.psychology_alt_outlined,
    color: MedixColors.warning,
    fields: const [
      _ToolField.choice(
        'eye',
        'Otvaranje očiju',
        [
          _ChoiceOption(4, 'Spontano · 4'),
          _ChoiceOption(3, 'Na govor · 3'),
          _ChoiceOption(2, 'Na bol · 2'),
          _ChoiceOption(1, 'Bez odgovora · 1'),
        ],
        initialValue: 4,
      ),
      _ToolField.choice(
        'verbal',
        'Verbalni odgovor',
        [
          _ChoiceOption(5, 'Orijentiran · 5'),
          _ChoiceOption(4, 'Konfuzan · 4'),
          _ChoiceOption(3, 'Neprimjerene riječi · 3'),
          _ChoiceOption(2, 'Nerazumljivi glasovi · 2'),
          _ChoiceOption(1, 'Bez odgovora · 1'),
        ],
        initialValue: 5,
      ),
      _ToolField.choice(
        'motor',
        'Motorički odgovor',
        [
          _ChoiceOption(6, 'Izvršava naredbe · 6'),
          _ChoiceOption(5, 'Lokalizira bol · 5'),
          _ChoiceOption(4, 'Povlačenje na bol · 4'),
          _ChoiceOption(3, 'Abnormalna fleksija · 3'),
          _ChoiceOption(2, 'Ekstenzija · 2'),
          _ChoiceOption(1, 'Bez odgovora · 1'),
        ],
        initialValue: 6,
      ),
    ],
    calculate: (values) {
      final eye = _choice(values, 'eye', 'otvaranje očiju');
      final verbal = _choice(values, 'verbal', 'verbalni odgovor');
      final motor = _choice(values, 'motor', 'motorički odgovor');
      final score = eye + verbal + motor;
      return _ToolResult(
        'GCS $score / 15',
        'E $eye + V $verbal + M $motor.',
      );
    },
  ),
  _ToolDefinition(
    title: 'MELD',
    subtitle: 'Klasični MELD rezultat',
    description:
        'Klasični MELD iz bilirubina, INR-a i kreatinina. Za suvremene odluke provjerite protokol ustanove.',
    icon: Icons.biotech_outlined,
    color: MedixColors.warning,
    fields: const [
      _ToolField.number('bilirubin', 'Bilirubin', unit: 'mg/dL'),
      _ToolField.number('inr', 'INR'),
      _ToolField.number('creatinine', 'Kreatinin', unit: 'mg/dL'),
      _ToolField.toggle(
        'dialysis',
        'Dijaliza u posljednjem tjednu',
      ),
    ],
    calculate: (values) {
      var bilirubin = _number(values, 'bilirubin', 'bilirubin');
      var inr = _number(values, 'inr', 'INR');
      var creatinine =
          _number(values, 'creatinine', 'kreatinin');
      bilirubin = math.max(1.0, bilirubin).toDouble();
      inr = math.max(1.0, inr).toDouble();
      creatinine = _flag(values, 'dialysis')
          ? 4
          : math.min(4, math.max(1, creatinine));
      final meld = 3.78 * math.log(bilirubin) +
          11.2 * math.log(inr) +
          9.57 * math.log(creatinine) +
          6.43;
      return _ToolResult(
        'MELD ${meld.round()}',
        'Klasična formula; rezultat treba tumačiti prema aktualnom protokolu.',
      );
    },
  ),
  _ToolDefinition(
    title: 'PERC',
    subtitle: 'Kriteriji za plućnu emboliju',
    description:
        'Broji pozitivne PERC kriterije. Primjena kriterija ovisi o prethodnoj kliničkoj vjerojatnosti.',
    icon: Icons.air_rounded,
    color: MedixColors.cyan,
    fields: const [
      _ToolField.number('age', 'Dob', unit: 'god.'),
      _ToolField.number('heartRate', 'Puls', unit: '/min'),
      _ToolField.number('spo2', 'SpO₂', unit: '%'),
      _ToolField.toggle('leg', 'Jednostrano oticanje noge'),
      _ToolField.toggle('hemoptysis', 'Hemoptiza'),
      _ToolField.toggle('surgery', 'Nedavna operacija / trauma'),
      _ToolField.toggle('vte', 'Prethodni DVT / PE'),
      _ToolField.toggle('estrogen', 'Egzogeni estrogen'),
    ],
    calculate: (values) {
      final age = _number(values, 'age', 'dob');
      final heartRate = _number(values, 'heartRate', 'puls');
      final spo2 = _number(values, 'spo2', 'SpO₂');
      var score = 0;
      if (age >= 50) score++;
      if (heartRate >= 100) score++;
      if (spo2 < 95) score++;
      for (final id in [
        'leg',
        'hemoptysis',
        'surgery',
        'vte',
        'estrogen',
      ]) {
        if (_flag(values, id)) score++;
      }
      return _ToolResult(
        '$score pozitivnih kriterija',
        'Prikazan je broj pozitivnih PERC kriterija.',
      );
    },
  ),
  _ToolDefinition(
    title: 'Wells · PE',
    subtitle: 'Wellsov bodovni sustav',
    description:
        'Izračun Wellsovih bodova za plućnu emboliju bez automatske terapijske preporuke.',
    icon: Icons.monitor_heart_outlined,
    color: MedixColors.primary,
    fields: const [
      _ToolField.toggle('dvt', 'Klinički znakovi DVT-a'),
      _ToolField.toggle(
        'peLikely',
        'PE je klinički vjerojatnija od alternativne dijagnoze',
      ),
      _ToolField.toggle('tachy', 'Puls > 100/min'),
      _ToolField.toggle(
        'immobilization',
        'Imobilizacija / operacija u zadnja 4 tjedna',
      ),
      _ToolField.toggle('previous', 'Prethodni DVT / PE'),
      _ToolField.toggle('hemoptysis', 'Hemoptiza'),
      _ToolField.toggle('malignancy', 'Aktivna malignost'),
    ],
    calculate: (values) {
      var score = 0.0;
      if (_flag(values, 'dvt')) score += 3;
      if (_flag(values, 'peLikely')) score += 3;
      if (_flag(values, 'tachy')) score += 1.5;
      if (_flag(values, 'immobilization')) score += 1.5;
      if (_flag(values, 'previous')) score += 1.5;
      if (_flag(values, 'hemoptysis')) score += 1;
      if (_flag(values, 'malignancy')) score += 1;
      return _ToolResult(
        '${score.toStringAsFixed(score % 1 == 0 ? 0 : 1)} bodova',
        'Wells PE zbroj. Pragove i daljnji postupak provjerite prema protokolu.',
      );
    },
  ),
];
