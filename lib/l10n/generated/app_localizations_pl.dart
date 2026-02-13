// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Vamos';

  @override
  String get retry => 'Ponów';

  @override
  String get cancel => 'Anuluj';

  @override
  String get save => 'Zapisz';

  @override
  String comingSoon(String feature) {
    return '$feature — wkrótce!';
  }

  @override
  String get or => 'LUB';

  @override
  String get required => 'Wymagane';

  @override
  String get navRides => 'Przejazdy';

  @override
  String get navPackages => 'Paczki';

  @override
  String get navProfile => 'Profil';

  @override
  String get navMessages => 'Wiadomości';

  @override
  String get loginTitle => 'Logowanie';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Hasło';

  @override
  String get enterEmail => 'Podaj adres e-mail';

  @override
  String get enterValidEmail => 'Podaj poprawny adres e-mail';

  @override
  String get enterPassword => 'Podaj hasło';

  @override
  String get continueWithGoogle => 'Kontynuuj z Google';

  @override
  String get dontHaveAccount => 'Nie masz konta? ';

  @override
  String get signUp => 'Zarejestruj się';

  @override
  String get createAccountTitle => 'Utwórz konto';

  @override
  String get displayNameLabel => 'Wyświetlana nazwa';

  @override
  String get displayNameHelper => 'Tę nazwę będą widzieć inni użytkownicy.';

  @override
  String get enterDisplayName => 'Podaj wyświetlaną nazwę';

  @override
  String get displayNameMinLength => 'Nazwa musi mieć co najmniej 2 znaki';

  @override
  String get confirmPasswordLabel => 'Potwierdź hasło';

  @override
  String get confirmPassword => 'Potwierdź swoje hasło';

  @override
  String get passwordsDoNotMatch => 'Hasła się nie zgadzają';

  @override
  String get enterAPassword => 'Podaj hasło';

  @override
  String get passwordMinLength => 'Hasło musi mieć co najmniej 6 znaków';

  @override
  String get alreadyHaveAccount => 'Masz już konto? ';

  @override
  String get googleSignUpComingSoon => 'Rejestracja przez Google wkrótce!';

  @override
  String searchSemanticLabel(String label) {
    return 'Szukaj przejazdów. $label';
  }

  @override
  String get swapOriginDestination => 'Zamień początek i cel';

  @override
  String get whereToSearch => 'Dokąd?';

  @override
  String searchFromCity(String city) {
    return 'Z $city';
  }

  @override
  String searchToCity(String city) {
    return 'Do $city';
  }

  @override
  String searchRoute(String origin, String destination) {
    return '$origin → $destination';
  }

  @override
  String get myRides => 'Moje przejazdy';

  @override
  String get post => 'Dodaj';

  @override
  String get whatAreYouPosting => 'Co chcesz dodać?';

  @override
  String get offerARide => 'Oferuję przejazd';

  @override
  String get offerARideSubtitle => 'Jadę samochodem i mam wolne miejsca.';

  @override
  String get requestARide => 'Szukam przejazdu';

  @override
  String get requestARideSubtitle => 'Potrzebuję kierowcy na konkretny termin.';

  @override
  String get today => 'Dziś';

  @override
  String get tomorrow => 'Jutro';

  @override
  String get previousDay => 'Poprzedni dzień';

  @override
  String get nextDay => 'Następny dzień';

  @override
  String get partOfDayMorning => 'Rano';

  @override
  String get partOfDayAfternoon => 'Popołudnie';

  @override
  String get partOfDayEvening => 'Wieczór';

  @override
  String get partOfDayNight => 'Noc';

  @override
  String get anyTime => 'Dowolna pora';

  @override
  String get flexible => 'Elastycznie';

  @override
  String get askDriver => 'Zapytaj kierowcę';

  @override
  String get askAboutPrice => 'Zapytaj o cenę';

  @override
  String get askPassenger => 'Zapytaj pasażera';

  @override
  String offerDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String dateStripDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String formattedPrice(int price) {
    return '$price PLN';
  }

  @override
  String get unknownPrice => '? PLN';

  @override
  String seatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miejsca',
      many: '$count miejsc',
      few: '$count miejsca',
      one: '1 miejsce',
    );
    return '$_temp0';
  }

  @override
  String passengerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasażerów',
      many: '$count pasażerów',
      few: '$count pasażerów',
      one: '1 pasażer',
    );
    return '$_temp0';
  }

  @override
  String rideCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count przejazdu',
      many: '$count przejazdów',
      few: '$count przejazdy',
      one: '1 przejazd',
    );
    return '$_temp0';
  }

  @override
  String get pricePerSeat => 'Cena za miejsce';

  @override
  String get availableSeats => 'Wolne miejsca';

  @override
  String get budget => 'Budżet';

  @override
  String get passengers => 'Pasażerowie';

  @override
  String get passengersNeeded => 'Liczba pasażerów';

  @override
  String get verifiedMember => 'Zweryfikowany użytkownik';

  @override
  String get communityListing => 'Ogłoszenie społecznościowe';

  @override
  String get sourceFacebook => 'Źródło: Facebook';

  @override
  String get callLabel => 'Zadzwoń';

  @override
  String get openFacebookPost => 'Otwórz post na Facebooku';

  @override
  String get sendEmail => 'Wyślij e-mail';

  @override
  String get rideDetails => 'Szczegóły przejazdu';

  @override
  String get rideRequest => 'Prośba o przejazd';

  @override
  String get offeringARide => 'Oferuje przejazd';

  @override
  String get lookingForARide => 'Szuka przejazdu';

  @override
  String contactUser(String name) {
    return 'Kontakt z $name';
  }

  @override
  String get facebookUser => 'Użytkownik Facebooka';

  @override
  String get priceLabel => 'Cena';

  @override
  String get availabilityLabel => 'Dostępność';

  @override
  String get driverLabel => 'KIEROWCA';

  @override
  String get passengerLabel => 'PASAŻER';

  @override
  String get driverFallbackName => 'Kierowca';

  @override
  String get passengerFallbackName => 'Pasażer';

  @override
  String ratingDisplay(String rating, int count) {
    return '$rating ($count)';
  }

  @override
  String get statusOpen => 'Otwarte';

  @override
  String get statusFull => 'Pełne';

  @override
  String get statusCompleted => 'Zakończone';

  @override
  String get statusCancelled => 'Anulowane';

  @override
  String get statusSearching => 'Szukam';

  @override
  String get statusBooked => 'Zarezerwowane';

  @override
  String get statusExpired => 'Wygasłe';

  @override
  String get statusBanned => 'Zablokowane';

  @override
  String get noRidesFound =>
      'Nie znaleziono przejazdów pasujących do Twoich kryteriów.';

  @override
  String get noPassengerRequests =>
      'Nie znaleziono próśb pasażerów pasujących do Twoich kryteriów.';

  @override
  String get myOffers => 'Moje ogłoszenia';

  @override
  String get filterAll => 'Wszystkie';

  @override
  String get filterRides => 'Przejazdy';

  @override
  String get filterPassengers => 'Pasażerowie';

  @override
  String get failedToLoadOffers => 'Nie udało się załadować ogłoszeń';

  @override
  String get noOffersYet => 'Brak ogłoszeń';

  @override
  String get postYourRide => 'Dodaj przejazd';

  @override
  String get offerARideHeader => 'Oferuję przejazd';

  @override
  String get originCityLabel => 'Miasto początkowe';

  @override
  String get destinationCityLabel => 'Miasto docelowe';

  @override
  String get originRequired => 'Miasto początkowe jest wymagane';

  @override
  String get destinationRequired => 'Miasto docelowe jest wymagane';

  @override
  String get selectOriginFromSuggestions =>
      'Wybierz miasto z listy podpowiedzi';

  @override
  String get selectDestinationFromSuggestions =>
      'Wybierz cel z listy podpowiedzi';

  @override
  String get mustDifferFromOrigin => 'Musi się różnić od miasta początkowego';

  @override
  String get dateOfDeparture => 'Data wyjazdu';

  @override
  String get selectDepartureDate => 'Wybierz datę wyjazdu';

  @override
  String get timeOfDay => 'Pora dnia';

  @override
  String get timeOfDeparture => 'Godzina wyjazdu';

  @override
  String get selectDepartureTime => 'Wybierz godzinę wyjazdu';

  @override
  String get availableSeatsLabel => 'Wolne miejsca';

  @override
  String get seatsRange => 'Dozwolone 1–8 miejsc';

  @override
  String get pricePerSeatLabel => 'Cena za miejsce';

  @override
  String get priceRange => '1–999 PLN';

  @override
  String get rideDescriptionOptional => 'Opis przejazdu (opcjonalnie)';

  @override
  String maxCharacters(int count) {
    return 'Maks. $count znaków';
  }

  @override
  String get postRide => 'Dodaj przejazd';

  @override
  String get postSeatRequest => 'Dodaj prośbę o przejazd';

  @override
  String get findARideHeader => 'Szukam przejazdu';

  @override
  String get passengersRange => 'Dozwolone 1–8 pasażerów';

  @override
  String get budgetOptional => 'Budżet (opcjonalnie)';

  @override
  String get descriptionOptional => 'Opis (opcjonalnie)';

  @override
  String get seatRequestCreated => 'Prośba o przejazd została dodana!';

  @override
  String get profileTitle => 'Profil';

  @override
  String get logInToSeeProfile => 'Zaloguj się, aby zobaczyć swój profil';

  @override
  String get logInSignUp => 'Zaloguj / Zarejestruj';

  @override
  String get trustAndVerification => 'Zaufanie i weryfikacja';

  @override
  String get emailVerification => 'Weryfikacja e-mail';

  @override
  String get phoneVerification => 'Weryfikacja telefonu';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get statistics => 'Statystyki';

  @override
  String get ridesGiven => 'Udzielone przejazdy';

  @override
  String get ridesTaken => 'Odbyte przejazdy';

  @override
  String get rating => 'Ocena';

  @override
  String get editProfile => 'Edytuj profil';

  @override
  String get updatePersonalInfo => 'Zaktualizuj swoje dane osobowe';

  @override
  String get viewRideHistory => 'Zobacz historię przejazdów';

  @override
  String get logout => 'Wyloguj';

  @override
  String get phoneNumberLabel => 'Numer telefonu';

  @override
  String get phoneHint => 'Podaj numer telefonu (opcjonalnie)';

  @override
  String get bioLabel => 'O mnie';

  @override
  String get bioHint => 'Napisz coś o sobie (opcjonalnie)';

  @override
  String get displayNameRequired => 'Nazwa wyświetlana jest wymagana';

  @override
  String get saveChanges => 'Zapisz zmiany';

  @override
  String get profileUpdatedSuccess => 'Profil został zaktualizowany';

  @override
  String get failedToUpdateProfile => 'Nie udało się zaktualizować profilu';

  @override
  String get profileCompleteness => 'Kompletność profilu';

  @override
  String get profileComplete => 'Profil kompletny!';

  @override
  String percentComplete(int percent) {
    return '$percent% ukończone';
  }

  @override
  String get complete => 'Uzupełnij';

  @override
  String get profileNotAvailable => 'Profil niedostępny';

  @override
  String get profileNotAvailableMessage =>
      'Tego profilu nie można teraz wyświetlić.';

  @override
  String get about => 'O mnie';

  @override
  String get noBioYet => 'Brak opisu.';

  @override
  String get rides => 'Przejazdy';

  @override
  String get reviews => 'Opinie';

  @override
  String get vehicle => 'Pojazd';

  @override
  String get myBookings => 'Moje rezerwacje';

  @override
  String get bookingsComingSoon => 'Rezerwacje wkrótce';

  @override
  String get bookingsComingSoonMessage =>
      'Funkcja rezerwacji jest w trakcie przebudowy. Sprawdź później!';

  @override
  String get messagesTitle => 'Wiadomości';

  @override
  String get chatTitle => 'Czat';

  @override
  String get couldNotLoadMessages => 'Nie udało się załadować wiadomości';

  @override
  String get noMessagesYet => 'Brak wiadomości';

  @override
  String get startConversation => 'Rozpocznij rozmowę z poziomu ogłoszenia';

  @override
  String get sendMessageToStart => 'Wyślij wiadomość, aby rozpocząć rozmowę';

  @override
  String get typeAMessage => 'Napisz wiadomość...';

  @override
  String get timeNow => 'teraz';

  @override
  String timeMinutesAgo(int count) {
    return '$count min';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count godz.';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count dn.';
  }

  @override
  String get packagesTitle => 'Paczki';

  @override
  String get packagesComingSoon => 'Wkrótce';

  @override
  String get errorTitle => 'Błąd';

  @override
  String get pageNotFound => 'Nie znaleziono strony';

  @override
  String get pageNotFoundMessage => 'Strona, której szukasz, nie istnieje.';

  @override
  String get goHome => 'Wróć na stronę główną';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get languageSystem => 'Systemowy';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePolish => 'Polski';

  @override
  String effectiveLanguage(String language) {
    return 'Aktualnie: $language';
  }

  @override
  String get searchRides => 'Szukaj przejazdów';

  @override
  String get searchPassengers => 'Szukaj pasażerów';

  @override
  String get fromLabel => 'Skąd';

  @override
  String get toLabel => 'Dokąd';

  @override
  String get dateLabel => 'Data';

  @override
  String get anyDate => 'Dowolna data';

  @override
  String get clearDate => 'Wyczyść datę';

  @override
  String get clearAll => 'Wyczyść wszystko';

  @override
  String get chooseCity => 'Wybierz miasto';

  @override
  String get searchCity => 'Szukaj miasta';

  @override
  String get whereAreYouGoing => 'Dokąd jedziesz?';

  @override
  String nudgeRouteTime(String origin, String destination) {
    return 'Potrzebujesz innej godziny na trasie $origin → $destination?';
  }

  @override
  String nudgeDateFallback(String date) {
    return 'Nic na $date? Dodaj własne ogłoszenie.';
  }

  @override
  String get nudgeGeneric =>
      'Nie znajdujesz tego, czego szukasz? Dodaj ogłoszenie, a kierowcy sami się zgłoszą.';

  @override
  String get postARequest => 'Dodaj ogłoszenie';

  @override
  String get postRequest => 'Dodaj ogłoszenie';

  @override
  String get noRidesFoundShort => 'Nie znaleziono przejazdów';

  @override
  String get zeroResultsHeadline => 'Nie czekaj. Niech kierowcy znajdą Ciebie.';

  @override
  String zeroResultsRouteDate(String origin, String destination, String date) {
    return 'Dodaj ogłoszenie na trasie $origin do $destination na $date.';
  }

  @override
  String zeroResultsRoute(String origin, String destination) {
    return 'Dodaj ogłoszenie na trasie $origin do $destination.';
  }

  @override
  String zeroResultsOriginDate(String origin, String date) {
    return 'Dodaj ogłoszenie z $origin na $date.';
  }

  @override
  String zeroResultsOrigin(String origin) {
    return 'Dodaj ogłoszenie z $origin i pozwól kierowcom Cię znaleźć.';
  }

  @override
  String get zeroResultsGeneric =>
      'Dodaj ogłoszenie na swoją trasę i pozwól kierowcom Cię znaleźć.';

  @override
  String get negotiablePrice => 'Cena do negocjacji';

  @override
  String get addStop => 'Dodaj przystanek';

  @override
  String get removeStop => 'Usuń przystanek';

  @override
  String intermediateStopLabel(int number) {
    return 'Przystanek $number';
  }

  @override
  String get stopDepartureTime => 'Godzina odjazdu z przystanku';
}
