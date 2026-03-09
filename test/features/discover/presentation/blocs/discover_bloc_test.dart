import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ooh_mobile/core/utils/failures.dart';
import 'package:ooh_mobile/core/utils/result.dart';
import 'package:ooh_mobile/features/discover/data/api/inventory_api_service.dart';
import 'package:ooh_mobile/features/discover/data/dto/dictionary_ref_dto.dart';
import 'package:ooh_mobile/features/discover/data/repository/discover_repository.dart';
import 'package:ooh_mobile/features/discover/domain/entities/city.dart';
import 'package:ooh_mobile/features/discover/domain/entities/country.dart';
import 'package:ooh_mobile/features/discover/domain/entities/ooh_unit.dart';
import 'package:ooh_mobile/features/discover/presentation/blocs/discover_bloc.dart';

@GenerateNiceMocks([MockSpec<DiscoverRepository>()])
import 'discover_bloc_test.mocks.dart';

void main() {
  late MockDiscoverRepository mockRepository;

  setUpAll(() {
    // Mockito zahteva dummy vrednosti za sealed Result<T> tipove
    provideDummy<Result<List<Country>>>(const Success([]));
    provideDummy<Result<List<City>>>(const Success([]));
    provideDummy<Result<List<OohUnit>>>(const Success([]));
    provideDummy<Result<List<DictionaryRefDto>>>(const Success([]));
    provideDummy<Result<OohUnit>>(Success(OohUnit(
      id: '0',
      name: '',
      type: OohType.other,
      address: '',
      cityId: '0',
      cityName: '',
      latitude: 0,
      longitude: 0,
      price: 0,
      status: OohStatus.available,
    )));
  });

  final testCountries = [
    const Country(id: 1, name: 'Srbija', code: 'RS'),
    const Country(id: 2, name: 'Hrvatska', code: 'HR'),
    const Country(id: 3, name: 'Bosna i Hercegovina', code: 'BA'),
  ];

  final testCities = [
    City(
      id: 1,
      name: 'Beograd',
      country: 'Srbija',
      countryId: 1,
      latitude: 44.8,
      longitude: 20.5,
      inventoryCount: 10,
    ),
    City(
      id: 2,
      name: 'Novi Sad',
      country: 'Srbija',
      countryId: 1,
      latitude: 45.3,
      longitude: 19.8,
      inventoryCount: 5,
    ),
  ];

  final testCroatianCities = [
    City(
      id: 3,
      name: 'Zagreb',
      country: 'Hrvatska',
      countryId: 2,
      latitude: 45.8,
      longitude: 15.9,
      inventoryCount: 8,
    ),
  ];

  final testUnits = [
    const OohUnit(
      id: '1',
      name: 'Bilbord Centar',
      type: OohType.billboard,
      address: 'Knez Mihailova 10',
      cityId: '1',
      cityName: 'Beograd',
      latitude: 44.81,
      longitude: 20.46,
      price: 500.0,
      status: OohStatus.available,
    ),
    const OohUnit(
      id: '2',
      name: 'Digital Novi Beograd',
      type: OohType.digital,
      address: 'Bulevar Mihajla Pupina 5',
      cityId: '1',
      cityName: 'Beograd',
      latitude: 44.80,
      longitude: 20.41,
      price: 800.0,
      status: OohStatus.available,
    ),
  ];

  setUp(() {
    mockRepository = MockDiscoverRepository();
  });

  DiscoverBloc buildBloc() => DiscoverBloc(repository: mockRepository);

  group('LoadCountries', () {
    blocTest<DiscoverBloc, DiscoverState>(
      'emituje [DiscoverLoading, DiscoverLoaded] sa Srbijom kao default drzavom',
      build: () {
        when(mockRepository.getCountries())
            .thenAnswer((_) async => Success(testCountries));
        when(mockRepository.getCities(countryId: 1))
            .thenAnswer((_) async => Success(testCities));
        when(mockRepository.getUnits(filters: anyNamed('filters')))
            .thenAnswer((_) async => Success(testUnits));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadCountries()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        isA<DiscoverLoading>(),
        isA<DiscoverLoaded>()
            .having((s) => s.countries.length, 'countries.length', 3)
            .having((s) => s.selectedCountry?.code, 'selectedCountry.code', 'RS'),
        isA<DiscoverLoaded>()
            .having((s) => s.cities.length, 'cities.length', 2)
            .having((s) => s.selectedCity?.name, 'selectedCity', 'Beograd'),
        isA<DiscoverLoaded>()
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', true),
        isA<DiscoverLoaded>()
            .having((s) => s.units.length, 'units.length', 2),
      ],
    );

    blocTest<DiscoverBloc, DiscoverState>(
      'emituje DiscoverFailure na gresku pri ucitavanju drzava',
      build: () {
        when(mockRepository.getCountries())
            .thenAnswer((_) async => const Error(ServerFailure('Network error')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadCountries()),
      expect: () => [
        isA<DiscoverLoading>(),
        isA<DiscoverFailure>()
            .having((s) => s.message, 'message', contains('Network error')),
      ],
    );
  });

  group('SelectCountry', () {
    blocTest<DiscoverBloc, DiscoverState>(
      'selektuje novu drzavu i pokrece ucitavanje gradova za tu drzavu',
      build: () {
        when(mockRepository.getCities(countryId: 2))
            .thenAnswer((_) async => Success(testCroatianCities));
        when(mockRepository.getUnits(filters: anyNamed('filters')))
            .thenAnswer((_) async => const Success([]));
        return buildBloc();
      },
      seed: () => DiscoverLoaded(
        countries: testCountries,
        selectedCountry: testCountries[0],
        cities: testCities,
        units: testUnits,
        selectedCity: testCities[0],
      ),
      act: (bloc) => bloc.add(SelectCountry(testCountries[1])),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        // Emits with new country, cleared city and units
        isA<DiscoverLoaded>()
            .having((s) => s.selectedCountry?.name, 'selectedCountry', 'Hrvatska')
            .having((s) => s.selectedCity, 'selectedCity', isNull)
            .having((s) => s.cities.length, 'cities.length', 0),
        // Cities loaded for Croatia
        isA<DiscoverLoaded>()
            .having((s) => s.cities.length, 'cities.length', 1)
            .having((s) => s.selectedCity?.name, 'selectedCity', 'Zagreb'),
        // Units loading
        isA<DiscoverLoaded>()
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', true),
        // Units loaded
        isA<DiscoverLoaded>()
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', false),
      ],
    );

    blocTest<DiscoverBloc, DiscoverState>(
      'selektuje null drzavu ("Sve drzave") — ucitava sve gradove',
      build: () {
        when(mockRepository.getCities(countryId: null))
            .thenAnswer((_) async => Success([...testCities, ...testCroatianCities]));
        when(mockRepository.getUnits(filters: anyNamed('filters')))
            .thenAnswer((_) async => Success(testUnits));
        return buildBloc();
      },
      seed: () => DiscoverLoaded(
        countries: testCountries,
        selectedCountry: testCountries[0],
        cities: testCities,
        units: testUnits,
        selectedCity: testCities[0],
      ),
      act: (bloc) => bloc.add(const SelectCountry(null)),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        // Emits with cleared country and city
        isA<DiscoverLoaded>()
            .having((s) => s.selectedCountry, 'selectedCountry', isNull)
            .having((s) => s.selectedCity, 'selectedCity', isNull),
        // Cities loaded (all)
        isA<DiscoverLoaded>()
            .having((s) => s.cities.length, 'cities.length', 3)
            .having((s) => s.selectedCity?.name, 'selectedCity', 'Beograd'),
        // Units loading triggered
        isA<DiscoverLoaded>()
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', true),
        // Units loaded
        isA<DiscoverLoaded>()
            .having((s) => s.units.length, 'units.length', 2),
      ],
    );
  });

  group('LoadCities', () {
    blocTest<DiscoverBloc, DiscoverState>(
      'emituje [DiscoverLoading, DiscoverLoaded] sa Beogradom kao default gradom',
      build: () {
        when(mockRepository.getCities(countryId: null))
            .thenAnswer((_) async => Success(testCities));
        when(mockRepository.getUnits(filters: anyNamed('filters')))
            .thenAnswer((_) async => Success(testUnits));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadCities()),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        isA<DiscoverLoading>(),
        isA<DiscoverLoaded>()
            .having((s) => s.cities.length, 'cities.length', 2)
            .having((s) => s.selectedCity?.name, 'selectedCity', 'Beograd'),
        isA<DiscoverLoaded>()
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', true),
        isA<DiscoverLoaded>()
            .having((s) => s.units.length, 'units.length', 2),
      ],
    );

    blocTest<DiscoverBloc, DiscoverState>(
      'emituje [DiscoverLoading, DiscoverLoaded] sa praznom listom gradova i ucitava sve jedinice',
      build: () {
        when(mockRepository.getCities(countryId: null))
            .thenAnswer((_) async => const Success([]));
        when(mockRepository.getUnits(filters: anyNamed('filters')))
            .thenAnswer((_) async => Success(testUnits));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadCities()),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        isA<DiscoverLoading>(),
        isA<DiscoverLoaded>()
            .having((s) => s.cities.length, 'cities.length', 0)
            .having((s) => s.units.length, 'units.length', 0),
        // When countryId is null and no cities, it loads all units
        isA<DiscoverLoaded>()
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', true),
        isA<DiscoverLoaded>()
            .having((s) => s.units.length, 'units.length', 2),
      ],
    );

    blocTest<DiscoverBloc, DiscoverState>(
      'emituje [DiscoverLoading, DiscoverFailure] na gresku',
      build: () {
        when(mockRepository.getCities(countryId: null))
            .thenAnswer((_) async => const Error(ServerFailure('Network error')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadCities()),
      expect: () => [
        isA<DiscoverLoading>(),
        isA<DiscoverFailure>()
            .having((s) => s.message, 'message', contains('Network error')),
      ],
    );
  });

  group('LoadInventoryUnits', () {
    blocTest<DiscoverBloc, DiscoverState>(
      'emituje ucitane jedinice kada postoji DiscoverLoaded stanje',
      build: () {
        when(mockRepository.getCities(countryId: null))
            .thenAnswer((_) async => Success(testCities));
        when(mockRepository.getUnits(filters: anyNamed('filters')))
            .thenAnswer((_) async => Success(testUnits));
        return buildBloc();
      },
      seed: () => DiscoverLoaded(
        cities: testCities,
        units: const [],
        selectedCity: testCities[0],
      ),
      act: (bloc) => bloc.add(const LoadInventoryUnits(cityId: 1)),
      expect: () => [
        isA<DiscoverLoaded>()
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', true),
        isA<DiscoverLoaded>()
            .having((s) => s.units.length, 'units.length', 2)
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', false),
      ],
    );

    blocTest<DiscoverBloc, DiscoverState>(
      'emituje DiscoverFailure na gresku pri ucitavanju inventara',
      build: () {
        when(mockRepository.getUnits(filters: anyNamed('filters')))
            .thenAnswer((_) async => const Error(ServerFailure('Server error')));
        return buildBloc();
      },
      seed: () => DiscoverLoaded(
        cities: testCities,
        units: const [],
        selectedCity: testCities[0],
      ),
      act: (bloc) => bloc.add(const LoadInventoryUnits(cityId: 1)),
      expect: () => [
        isA<DiscoverLoaded>()
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', true),
        isA<DiscoverFailure>()
            .having((s) => s.message, 'message', contains('Server error')),
      ],
    );
  });

  group('SelectCity', () {
    blocTest<DiscoverBloc, DiscoverState>(
      'azurira selectedCity i pokrece LoadInventoryUnits',
      build: () {
        when(mockRepository.getUnits(filters: anyNamed('filters')))
            .thenAnswer((_) async => const Success([]));
        return buildBloc();
      },
      seed: () => DiscoverLoaded(
        cities: testCities,
        units: testUnits,
        selectedCity: testCities[0],
      ),
      act: (bloc) => bloc.add(SelectCity(testCities[1])),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        isA<DiscoverLoaded>()
            .having((s) => s.selectedCity?.name, 'selectedCity', 'Novi Sad')
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', true),
        isA<DiscoverLoaded>()
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', false),
      ],
    );

    blocTest<DiscoverBloc, DiscoverState>(
      'postavlja selectedCity na null i ucitava sve jedinice za drzavu',
      build: () {
        when(mockRepository.getUnits(filters: anyNamed('filters')))
            .thenAnswer((_) async => Success(testUnits));
        return buildBloc();
      },
      seed: () => DiscoverLoaded(
        countries: testCountries,
        selectedCountry: testCountries[0],
        cities: testCities,
        units: testUnits,
        selectedCity: testCities[0],
      ),
      act: (bloc) => bloc.add(const SelectCity(null)),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        isA<DiscoverLoaded>()
            .having((s) => s.selectedCity, 'selectedCity', isNull)
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', true),
        isA<DiscoverLoaded>()
            .having((s) => s.selectedCity, 'selectedCity', isNull)
            .having((s) => s.units.length, 'units.length', 2)
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', false),
      ],
    );
  });

  group('ApplyFilters', () {
    blocTest<DiscoverBloc, DiscoverState>(
      'merge-uje filtere sa aktivnim gradom i pokrece ucitavanje',
      build: () {
        when(mockRepository.getUnits(filters: anyNamed('filters')))
            .thenAnswer((_) async => Success([testUnits[0]]));
        return buildBloc();
      },
      seed: () => DiscoverLoaded(
        cities: testCities,
        units: testUnits,
        selectedCity: testCities[0],
      ),
      act: (bloc) => bloc.add(const ApplyFilters(
        InventoryFilterParams(minPrice: 100, keyword: 'bilbord'),
      )),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        isA<DiscoverLoaded>()
            .having((s) => s.activeFilters.keyword, 'keyword', 'bilbord')
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', true),
        isA<DiscoverLoaded>()
            .having((s) => s.units.length, 'units.length', 1)
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', false),
      ],
    );
  });

  group('ResetFilters', () {
    blocTest<DiscoverBloc, DiscoverState>(
      'resetuje filtere na prazne i pokrece ucitavanje',
      build: () {
        when(mockRepository.getUnits(filters: anyNamed('filters')))
            .thenAnswer((_) async => Success(testUnits));
        return buildBloc();
      },
      seed: () => DiscoverLoaded(
        cities: testCities,
        units: [testUnits[0]],
        selectedCity: testCities[0],
        activeFilters: const InventoryFilterParams(minPrice: 100, keyword: 'test'),
      ),
      act: (bloc) => bloc.add(ResetFilters()),
      wait: const Duration(milliseconds: 300),
      expect: () => [
        isA<DiscoverLoaded>()
            .having((s) => s.activeFilters.isEmpty, 'isEmpty', true)
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', true),
        isA<DiscoverLoaded>()
            .having((s) => s.units.length, 'units.length', 2)
            .having((s) => s.isLoadingUnits, 'isLoadingUnits', false),
      ],
    );
  });

  group('LoadDictionaries', () {
    blocTest<DiscoverBloc, DiscoverState>(
      'ucitava unitTypes, mediaFormats i venueTypes',
      build: () {
        when(mockRepository.getUnitTypes()).thenAnswer((_) async =>
            const Success([DictionaryRefDto(id: 1, name: 'Billboard')]));
        when(mockRepository.getMediaFormats()).thenAnswer((_) async =>
            const Success([DictionaryRefDto(id: 1, name: '6x3')]));
        when(mockRepository.getVenueTypes()).thenAnswer((_) async =>
            const Success([DictionaryRefDto(id: 1, name: 'Highway')]));
        return buildBloc();
      },
      seed: () => DiscoverLoaded(
        cities: testCities,
        units: const [],
        selectedCity: testCities[0],
      ),
      act: (bloc) => bloc.add(LoadDictionaries()),
      expect: () => [
        isA<DiscoverLoaded>()
            .having((s) => s.unitTypes.length, 'unitTypes', 1)
            .having((s) => s.mediaFormats.length, 'mediaFormats', 1)
            .having((s) => s.venueTypes.length, 'venueTypes', 1),
      ],
    );
  });
}
