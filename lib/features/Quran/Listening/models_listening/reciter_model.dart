class ReciterModel {
  final int id;
  final String name;
  final String imagePath;
  final String country;
  final String description;
  final String birthDate;
  final String? deathDate;

  const ReciterModel({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.country,
    required this.description,
    required this.birthDate,
     this.deathDate,
  });
}

final List<ReciterModel> reciters = [
  const ReciterModel(
    id: 51,
    name: 'Abdul Basit Abdus Samad',
    imagePath: 'assets/images/Abdul Basit Abdus Samad.png',
    country: 'Egypt',
    birthDate: '1927',
    deathDate: '1988',
    description:
    'A legendary Egyptian Quran reciter known for his powerful and melodic voice.',
  ),

  const ReciterModel(
    id: 118,
    name: 'Mahmoud Khalil Al Hussary',
    imagePath: 'assets/images/Mahmoud Khalil Al-Hussary.png',
    country: 'Egypt',
    birthDate: '1917',
    deathDate: '1980',
    description:
    'A renowned Egyptian reciter known for his precise and carefully articulated recitation.',
  ),

  const ReciterModel(
    id: 112,
    name: 'Muhammad Siddiq Al Minshawi',
    imagePath: 'assets/images/Muhammad Siddiq Al-Minshawi.png',
    country: 'Egypt',
    birthDate: '1920',
    deathDate: '1969',
    description:
    'An iconic Egyptian reciter famous for his deeply moving and humble recitation.',
  ),

  const ReciterModel(
    id: 76,
    name: 'Abdullah Ali Jaber',
    imagePath: 'assets/images/Abdullah Ali Jaber.png',
    country: 'Saudi Arabia',
    birthDate: '1954',
    deathDate: '2005',
    description:
    'A distinguished Saudi reciter and former Imam of the Grand Mosque in Makkah.',
  ),

  const ReciterModel(
    id: 92,
    name: 'Yasser Al Dosari',
    imagePath: 'assets/images/Yasser Al-Dosari.png',
    country: 'Saudi Arabia',
    birthDate: '1980',
    deathDate: '',
    description:
    'A prominent Saudi reciter known for his emotional and melodious Quran recitation.',
  ),
  const ReciterModel(
    id: 81,
    name: 'Faris Abbad',
    imagePath: 'assets/images/Faris Abbad.png',
    country: 'Yemen',
    birthDate: '1980',
    deathDate: '',
    description:
    'A distinguished Yemeni Quran reciter and Imam, known for his melodious and emotional recitation. He memorized the Quran in Sana’a and is known for his Quran recordings and work with Al Majd Quran Channel.',
  ),

  const ReciterModel(
    id: 123,
    name: 'Mishary Rashid Al Afasy',
    imagePath: 'assets/images/Mishary Rashid Al-Afasy.png',
    country: 'Kuwait',
    birthDate: '1976',
    deathDate: '',
    description:
    'A widely recognized Kuwaiti reciter and Imam known for his clear and expressive voice.',
  ),

  const ReciterModel(
    id: 5,
    name: 'Ahmed bin Ali Al Ajmi',
    imagePath: 'assets/images/Ahmed bin Ali Al-Ajmi.png',
    country: 'Saudi Arabia',
    birthDate: '1968',
    deathDate: '',
    description:
    'A well-known Saudi Quran reciter and Imam recognized for his beautiful voice.',
  ),

  const ReciterModel(
    id: 31,
    name: 'Saud Al Shuraim',
    imagePath: 'assets/images/Saud Al-Shuraim.png',
    country: 'Saudi Arabia',
    birthDate: '1966',
    deathDate: '',
    description:
    'A renowned Saudi Quran reciter and former Imam and Khatib of the Grand Mosque.',
  ),

  const ReciterModel(
    id: 30,
    name: 'Saad Al Ghamdi',
    imagePath: 'assets/images/Saad Al-Ghamdi.png',
    country: 'Saudi Arabia',
    birthDate: '1967',
    deathDate: '',
    description:
    'A beloved Saudi reciter known for his calm and clear complete Quran recitation.',
  ),

  const ReciterModel(
    id: 54,
    name: 'Abdul Rahman Al Sudais',
    imagePath: 'assets/images/Abdul Rahman Al Sudais .png',
    country: 'Saudi Arabia',
    birthDate: '1962',
    deathDate: '',
    description:
    'A prominent Saudi reciter and Imam of the Two Holy Mosques known worldwide.',
  ),

  const ReciterModel(
    id: 89,
    name: 'Hani Al Rifai',
    imagePath: 'assets/images/Hani Al-Rifai.png',
    country: 'Saudi Arabia',
    birthDate: '1974',
    deathDate: '',
    description:
    'A Saudi Quran reciter known for his emotional and distinctive recitation.',
  ),

  const ReciterModel(
    id: 24,
    name: 'Khalifa Al Tunaiji',
    imagePath: 'assets/images/Khalifa Al-Tunaiji.png',
    country: 'United Arab Emirates',
    birthDate: '1969',
    deathDate: '',
    description:
    'An Emirati Quran reciter known for his strong and distinctive voice.',
  ),

  const ReciterModel(
    id: 102,
    name: 'Maher Al Muaiqly',
    imagePath: 'assets/images/Maher Al-Muaiqly.png',
    country: 'Saudi Arabia',
    birthDate: '1969',
    deathDate: '',
    description:
    'A prominent Saudi reciter and Imam of the Grand Mosque in Makkah.',
  ),

  const ReciterModel(
    id: 217,
    name: 'Bandar Baleela',
    imagePath: 'assets/images/Bandar Baleela.png',
    country: 'Saudi Arabia',
    birthDate: '1975',
    deathDate: '',
    description:
    'A Saudi Quran reciter, Imam of the Grand Mosque, and member of the Council of Senior Scholars.',
  ),

  const ReciterModel(
    id: 4,
    name: 'Abu Bakr Al Shatri',
    imagePath: 'assets/images/Abu Bakr Al-Shatri.png',
    country: 'Saudi Arabia',
    birthDate: '1970',
    deathDate: '',
    description:
    'A renowned Saudi Quran reciter and Imam known for his distinctive voice.',
  ),
];