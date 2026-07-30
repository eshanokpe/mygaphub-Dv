import './regex.dart';

// const baseUrl = "https://app.mygaphub.com/api/v2";
// const imgPrefix = "https://app.mygaphub.com";
// const imgPrefixAssets = "https://app.mygaphub.com/api/v2/assets";
// const assetBaseUrl = "https://gappropertyhub.com/wp-json/custom-api";
// const hubImageUrl = "http://www.gapassethub.com";
// const shareBase = "https://app.mygaphub.com/api/v2";

const baseUrl = "https://appstaging.mygaphub.com/api/v2";
const imgPrefix = "https://appstaging.mygaphub.com/api/v2";
const imgPrefixAssets = "https://appstaging.mygaphub.com/assets";
const assetBaseUrl = "https://gappropertyhub.com/wp-json/custom-api";
const hubImageUrl = "https://www.gapassethub.com";
const shareBase = "https://appstaging.mygaphub.com/api/v2";

const token2 =
    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9hcHBzdGFnaW5nLm15Z2FwaHViLmNvbVwvYXBpXC92MlwvbXlnYXBcL2xvZ2luIiwiaWF0IjoxNjU3Nzg3MzQyLCJleHAiOjE2NjI5NzEzNDIsIm5iZiI6MTY1Nzc4NzM0MiwianRpIjoiWUhNTUtya1ViODlHQW5RRyIsInN1YiI6MzcsInBydiI6Ijg3ZTBhZjFlZjlmZDE1ODEyZmRlYzk3MTUzYTE0ZTBiMDQ3NTQ2YWEifQ.XZjLxr4tylO0Ex84L5BnlKvjH79XpmWNR1POt8048Zg';
// const keyAPI = "JX89-UT26-YC76-YW83";
const keyAPI = "HC66-HY31-MJ55-FG49";
final amountValidator = RegExInputFormatter.withRegex(
  '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$',
);

List<String> greetings = [
  '',
  'Happy New Month! Enjoy every bit of it.',
  'Are you on track with your finances?',
  'Got a plan, start implementing!',
  'Supercharge your finances today.',
  'Its a beautiful day cos you made it here!',
  'Good or bad, some feedback will definitely help!',
  'What are you up to today?',
  'What will you achieve in the next 7 days?',
  'We are what we think the most.',
  'You just made a smart move by logging in.',
  'You will be loved when you serve, purpose to serve today!',
  'Do you know what the number 12 represents?',
  'Purpose is the driver of success.',
  'You\'re super focused.',
  'The 3rd 7-day cycle of the month begin - Watch out!',
  'Here to serve, please give me some feedback today.',
  'What\'s your greatest ambition? say it out loud! ',
  'What\'s that one word that describes you?',
  'You\'re an amazing person!',
  'Relax and conquer all challenges today.',
  'Smile and be happy :)',
  'Last 7-day cycle, start counting successes!',
  'How\'s your liabilties doing so far?',
  'Remember to give yourself some treat today.',
  'You are larger than life, create good memories today.',
  'Make the most of today!',
  'Can you make someone laugh today?',
  'Always a special day, today.',
  'Go the extra mile - you\'ve got the strength.',
  'Start planning your finances for next month\'s success.',
  'Financial independence is in view if you\'re yet to obtain it.',
];

const currencyList = <String>[
  '-Select-',
  '\$ USD',
  '€ EUR',
  '£ GBP',
  '₦ NGN',
  'AU\$ AUD',
  '¥ JPY',
  'GH₵ GHS',
  'CA\$ CAD',
  'CHF CHF',
  'CN¥ CNY',
  'MX\$ MXN',
  'টকা INR',
  '₽. RUB',
  'R ZAR',
  'R\$ BRL',
  "د.إ.‏"
      " AED",
  "ر.س.‏"
      " SAR",
  "Rp IDR",
];
final Map<String, String> currencyFlags = {
  '\$ USD': 'assets/flags/usa.png',
  '€ EUR': 'assets/flags/eu.png',
  '£ GBP': 'assets/flags/gbp.png',
  '₦ NGN': 'assets/flags/ng.png',
  'AU\$ AUD': 'assets/flags/au.png',
  '¥ JPY': 'assets/flags/jp.png',
  'GH₵ GHS': 'assets/flags/gh.png',
  'CA\$ CAD': 'assets/flags/ca.png',
  'CHF CHF': 'assets/flags/ch.png',
  'CN¥ CNY': 'assets/flags/cn.png',
  'MX\$ MXN': 'assets/flags/mx.png',
  'টকা INR': 'assets/flags/in.png',
  '₽. RUB': 'assets/flags/ru.png',
  'R ZAR': 'assets/flags/za.png',
  'R\$ BRL': 'assets/flags/br.png',
  "د.إ.‏ AED": 'assets/flags/ae.png',
  "ر.س.‏ SAR": 'assets/flags/sa.png',
  "Rp IDR": 'assets/flags/id.png',
};

final List<Map<String, dynamic>> currencyFlagsRegister = [
  {
    'currency': 'USD',
    'symbol': '\$',
    'dialCode': '+1',
    'flag': 'assets/flags/usa.png',
    'countryCode': 'US',
  },
  {
    'currency': 'EUR',
    'symbol': '€',
    'dialCode': '+358',
    'flag': 'assets/flags/eu.png',
    'countryCode': 'FI',
  },
  {
    'currency': 'GBP',
    'symbol': '£',
    'dialCode': '+44',
    'flag': 'assets/flags/gbp.png',
    'countryCode': 'GB',
  },
  {
    'currency': 'NGN',
    'symbol': '₦',
    'dialCode': '+234',
    'flag': 'assets/flags/ng.png',
    'countryCode': 'NG',
  },
  {
    'currency': 'AUD',
    'symbol': 'AU\$',
    'dialCode': '+61',
    'flag': 'assets/flags/au.png',
    'countryCode': 'AU',
  },
  {
    'currency': 'JPY',
    'symbol': '¥',
    'dialCode': '+81',
    'flag': 'assets/flags/jp.png',
    'countryCode': 'JP',
  },
  {
    'currency': 'GHS',
    'symbol': 'GH₵',
    'dialCode': '+233',
    'flag': 'assets/flags/gh.png',
    'countryCode': 'GH',
  },
  {
    'currency': 'CAD',
    'symbol': 'CA\$',
    'dialCode': '+1',
    'flag': 'assets/flags/ca.png',
    'countryCode': 'CA',
  },
  {
    'currency': 'CHF',
    'symbol': 'CHF',
    'dialCode': '+41',
    'flag': 'assets/flags/ch.png',
    'countryCode': 'CH',
  },
  {
    'currency': 'CNY',
    'symbol': 'CN¥',
    'dialCode': '+86',
    'flag': 'assets/flags/cn.png',
    'countryCode': 'CN',
  },
  {
    'currency': 'MXN',
    'symbol': 'MX\$',
    'dialCode': '+52',
    'flag': 'assets/flags/mx.png',
    'countryCode': 'MX',
  },
  {
    'currency': 'INR',
    'symbol': '₹',
    'dialCode': '+91',
    'flag': 'assets/flags/in.png',
    'countryCode': 'IN',
  },
  {
    'currency': 'RUB',
    'symbol': '₽',
    'dialCode': '+7',
    'flag': 'assets/flags/ru.png',
    'countryCode': 'RU',
  },
  {
    'currency': 'ZAR',
    'symbol': 'R',
    'dialCode': '+27',
    'flag': 'assets/flags/za.png',
    'countryCode': 'ZA',
  },
  {
    'currency': 'BRL',
    'symbol': 'R\$',
    'dialCode': '+55',
    'flag': 'assets/flags/br.png',
    'countryCode': 'BR',
  },
  {
    'currency': 'AED',
    'symbol': 'د.إ',
    'dialCode': '+971',
    'flag': 'assets/flags/ae.png',
    'countryCode': 'AE',
  },
  {
    'currency': 'SAR',
    'symbol': 'ر.س',
    'dialCode': '+966',
    'flag': 'assets/flags/sa.png',
    'countryCode': 'SA',
  },
  {
    'currency': 'IDR',
    'symbol': 'Rp',
    'dialCode': '+62',
    'flag': 'assets/flags/id.png',
    'countryCode': 'ID',
  },
];

const asseTypes = <String>[
  '-Select-',
  'Agro Allied',
  'Rental Property',
  'Landed Property',
  'Crop Farm Production',
  'Animal Farm Production',
  'Franchise',
  'Cash',
  'Partnership',
  'Haulage Pro',
  'Haulage',
  'Transport Operations',
  'Others',
];

const currencyListS = <String>[
  'USD',
  'EUR',
  'GBP',
  'NGN',
  'AUD',
  'JPY',
  'GHS',
  'CAD',
  'CHF',
  'CNY',
  'MXN',
  'INR',
  'RUB',
  'ZAR',
  'BRL',
  "AED",
  "SAR",
  "IDR",
];

String splitit(String currency) {
  var a = currency.split(' ').toList();
  return a[0];
}

String splitit1(String currency) {
  var a = currency.split(' ').toList();
  return a[1];
}

const Map<String, String> currencyToPhonePrefix = {
  '\$ USD': '+1',
  '€ EUR':
      '+', // Generic for EU, consider a specific country if needed e.g. +33 for France
  '£ GBP': '+44',
  '₦ NGN': '+234',
  'AU\$ AUD': '+61',
  '¥ JPY': '+81',
  'GH₵ GHS': '+233',
  'CA\$ CAD': '+1',
  'CHF CHF': '+41',
  'CN¥ CNY': '+86',
  'MX\$ MXN': '+52',
  'টকা INR': '+91',
  '₽. RUB': '+7',
  'R ZAR': '+27',
  'R\$ BRL': '+55',
  "د.إ.‏ AED": '+971',
  "ر.س.‏ SAR": '+966',
  "Rp IDR": '+62',
  '-Select-': '', // No prefix if '-Select-' is chosen
};

