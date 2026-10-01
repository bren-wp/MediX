import '../models/drug_interaction.dart';
import '../models/medication.dart';

class MedicationRepository {
  const MedicationRepository({
    required this.medications,
    required this.interactions,
  });

  final List<Medication> medications;
  final List<DrugInteraction> interactions;

  factory MedicationRepository.demo() {
    final reviewed = DateTime(2026, 10, 1);

    return MedicationRepository(
      medications: [
        Medication(
          id: 'paracetamol-500',
          name: 'Paracetamol',
          activeIngredient: 'Paracetamol',
          strength: '500 mg',
          form: 'tablete',
          category: 'Protiv bolova i temperature',
          requiresPrescription: false,
          summary:
              'Demo zapis za prikaz strukture podataka o lijeku. Produkcijski sadržaj mora biti vezan uz provjereni službeni izvor.',
          uses: ['Bol', 'Povišena tjelesna temperatura'],
          dosageGuidance:
              'Za doziranje provjerite službenu uputu konkretnog proizvoda ili se obratite liječniku ili ljekarniku.',
          sideEffects: [
            'Moguće nuspojave ovise o konkretnom proizvodu i korisniku.',
          ],
          warnings: [
            'Ne prelaziti dozu navedenu u službenoj uputi proizvoda.',
          ],
          sourceLabel: 'Demo podatak — nije regulatorni izvor',
          lastReviewed: reviewed,
        ),
        Medication(
          id: 'ibuprofen-400',
          name: 'Ibuprofen',
          activeIngredient: 'Ibuprofen',
          strength: '400 mg',
          form: 'tablete',
          category: 'Protiv bolova i upale',
          requiresPrescription: false,
          summary:
              'Demo zapis nesteroidnog protuupalnog lijeka za razvoj korisničkog sučelja.',
          uses: ['Bol', 'Upalna stanja', 'Povišena tjelesna temperatura'],
          dosageGuidance:
              'Doziranje ovisi o proizvodu, dobi i zdravstvenom stanju. Provjerite službenu uputu.',
          sideEffects: [
            'Moguće probavne i druge nuspojave; provjerite službenu uputu.',
          ],
          warnings: [
            'Poseban oprez može biti potreban kod određenih bolesti i drugih terapija.',
          ],
          sourceLabel: 'Demo podatak — nije regulatorni izvor',
          lastReviewed: reviewed,
        ),
        Medication(
          id: 'amoxicillin-500',
          name: 'Amoksicilin',
          activeIngredient: 'Amoksicilin',
          strength: '500 mg',
          form: 'kapsule',
          category: 'Antibiotici',
          requiresPrescription: true,
          summary:
              'Demo zapis antibiotika. Antibiotici se koriste samo prema medicinskoj indikaciji i uputi zdravstvenog stručnjaka.',
          uses: [
            'Određene bakterijske infekcije prema procjeni liječnika',
          ],
          dosageGuidance:
              'Primjenjuje se prema liječničkoj uputi i službenim informacijama konkretnog proizvoda.',
          sideEffects: [
            'Nuspojave ovise o proizvodu i osobi; provjerite službenu uputu.',
          ],
          warnings: [
            'Ne uzimati antibiotik bez odgovarajuće medicinske indikacije.',
          ],
          sourceLabel: 'Demo podatak — nije regulatorni izvor',
          lastReviewed: reviewed,
        ),
        Medication(
          id: 'warfarin',
          name: 'Varfarin',
          activeIngredient: 'Varfarin',
          strength: 'različite jačine',
          form: 'tablete',
          category: 'Antikoagulansi',
          requiresPrescription: true,
          summary:
              'Demo zapis antikoagulansa za razvoj modula interakcija i upozorenja.',
          uses: [
            'Antikoagulantna terapija prema liječničkoj procjeni',
          ],
          dosageGuidance:
              'Dozu individualno određuje zdravstveni stručnjak uz odgovarajuće praćenje.',
          sideEffects: [
            'Krvarenje i druge nuspojave zahtijevaju pažljivo praćenje.',
          ],
          warnings: [
            'Može imati klinički važne interakcije s drugim lijekovima i hranom.',
          ],
          sourceLabel: 'Demo podatak — nije regulatorni izvor',
          lastReviewed: reviewed,
        ),
        Medication(
          id: 'loratadine-10',
          name: 'Loratadin',
          activeIngredient: 'Loratadin',
          strength: '10 mg',
          form: 'tablete',
          category: 'Alergije',
          requiresPrescription: false,
          summary:
              'Demo zapis antihistaminika za razvoj pretrage i kategorija.',
          uses: ['Simptomi određenih alergijskih stanja'],
          dosageGuidance:
              'Provjerite službenu uputu konkretnog proizvoda.',
          sideEffects: [
            'Moguće nuspojave navedene su u službenoj uputi proizvoda.',
          ],
          warnings: [
            'Kod dvojbe se savjetujte s liječnikom ili ljekarnikom.',
          ],
          sourceLabel: 'Demo podatak — nije regulatorni izvor',
          lastReviewed: reviewed,
        ),
        Medication(
          id: 'omeprazole-20',
          name: 'Omeprazol',
          activeIngredient: 'Omeprazol',
          strength: '20 mg',
          form: 'kapsule',
          category: 'Probavni sustav',
          requiresPrescription: false,
          summary: 'Demo zapis za razvoj kategorija i detalja lijeka.',
          uses: [
            'Stanja povezana sa želučanom kiselinom, ovisno o proizvodu i indikaciji',
          ],
          dosageGuidance:
              'Provjerite službenu uputu konkretnog proizvoda.',
          sideEffects: [
            'Moguće nuspojave navedene su u službenoj uputi proizvoda.',
          ],
          warnings: [
            'Dugotrajniju primjenu treba uskladiti sa stručnim savjetom.',
          ],
          sourceLabel: 'Demo podatak — nije regulatorni izvor',
          lastReviewed: reviewed,
        ),
      ],
      interactions: const [
        DrugInteraction(
          firstMedicationId: 'warfarin',
          secondMedicationId: 'ibuprofen-400',
          severity: InteractionSeverity.significant,
          summary:
              'Poznata kombinacija koja može povećati rizik od krvarenja i zahtijeva stručnu procjenu.',
          guidance:
              'Nemojte mijenjati terapiju na temelju aplikacije. Obratite se liječniku ili ljekarniku.',
        ),
      ],
    );
  }

  List<Medication> search(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return medications;
    }

    return medications.where((medication) {
      final haystack = [
        medication.name,
        medication.activeIngredient,
        medication.category,
        medication.summary,
        ...medication.uses,
      ].join(' ').toLowerCase();

      return haystack.contains(query);
    }).toList();
  }

  List<String> get categories {
    final result = medications.map((item) => item.category).toSet().toList()
      ..sort();
    return result;
  }

  List<Medication> byCategory(String category) {
    return medications.where((item) => item.category == category).toList();
  }

  DrugInteraction? interactionBetween(String firstId, String secondId) {
    if (firstId == secondId) {
      return null;
    }

    for (final interaction in interactions) {
      if (interaction.matches(firstId, secondId)) {
        return interaction;
      }
    }
    return null;
  }
}
