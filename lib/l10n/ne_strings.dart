/// English text -> Nepali. Anything missing falls back to the English text.
/// Digits are converted to Devanagari numerals automatically.
const neStrings = <String, String>{
  // Onboarding
  'Sajil Yatra': 'सजिल यात्रा',
  'Every bus, micro and Safa Tempo in Kathmandu Valley, live on one map.':
      'काठमाडौँ उपत्यकाका सबै बस, माइक्रो र सफा टेम्पो, एउटै नक्सामा प्रत्यक्ष।',
  'CHOOSE YOUR LANGUAGE': 'आफ्नो भाषा छान्नुहोस्',
  'Get started': 'सुरु गर्नुहोस्',
  'Already have an account? ': 'खाता पहिल्यै छ? ',
  'Log in': 'लगइन गर्नुहोस्',
  'Language': 'भाषा',
  'English': 'English',
  'Choose your profile': 'आफ्नो प्रोफाइल छान्नुहोस्',
  'Select how you travel or operate in Kathmandu Valley so we can tailor fares and routes for you.':
      'तपाईं काठमाडौँ उपत्यकामा कसरी यात्रा वा सञ्चालन गर्नुहुन्छ भनी छान्नुहोस्, ताकि हामी तपाईंका लागि भाडा र रुट मिलाउन सकौँ।',
  'SELECT ROLE': 'भूमिका छान्नुहोस्',
  'Commuter': 'यात्री',
  'Regular daily passenger with standard fare':
      'मानक भाडा तिर्ने नियमित दैनिक यात्री',
  'Student': 'विद्यार्थी',
  'Eligible for 45% student fare discount': '45% विद्यार्थी भाडा छुटको हकदार',
  'Senior Citizen': 'ज्येष्ठ नागरिक',
  'Eligible for senior citizen fare concession':
      'ज्येष्ठ नागरिक भाडा सुविधाको हकदार',
  'Conductor / Driver': 'कन्डक्टर / चालक',
  'Share live vehicle location and manage routes':
      'सवारीको प्रत्यक्ष स्थान साझा गर्नुहोस् र रुट व्यवस्थापन गर्नुहोस्',
  'Continue': 'जारी राख्नुहोस्',

  // Register and login
  'Create account': 'खाता बनाउनुहोस्',
  'Registering as {}': '{} को रूपमा दर्ता गर्दै',
  'Full name': 'पुरा नाम',
  'Enter your name': 'आफ्नो नाम हाल्नुहोस्',
  'Email': 'इमेल',
  'Enter a valid email': 'मान्य इमेल हाल्नुहोस्',
  'Phone number': 'फोन नम्बर',
  'Enter a 10-digit phone number': '10 अङ्कको फोन नम्बर हाल्नुहोस्',
  'Password': 'पासवर्ड',
  'At least 6 characters': 'कम्तीमा 6 अक्षर',
  'Confirm password': 'पासवर्ड पुष्टि गर्नुहोस्',
  'Passwords do not match': 'पासवर्ड मिलेन',
  'Register': 'दर्ता गर्नुहोस्',
  'Continue as guest': 'अतिथिका रूपमा जारी राख्नुहोस्',
  'Welcome aboard, {}!': 'स्वागत छ, {}!',
  'Sign in': 'साइन इन',
  'Welcome back': 'फेरि स्वागत छ',
  'Enter your password': 'आफ्नो पासवर्ड हाल्नुहोस्',
  'Forgot password?': 'पासवर्ड बिर्सनुभयो?',
  'Login': 'लगइन',
  "Don't have an account? ": 'खाता छैन? ',
  'Sign up': 'साइन अप',

  // Panic alert
  'Panic alert': 'आपतकालीन संकेत',
  'Send your SOS message to your emergency contacts without anyone noticing.':
      'कसैलाई थाहा नदिई आफ्ना आपतकालीन सम्पर्कहरूलाई एसओएस सन्देश पठाउनुहोस्।',
  'Shake the phone hard 3 times': 'फोनलाई जोडले 3 पटक हल्लाउनुहोस्',
  'Press a volume button twice': 'भोल्युम बटन दुई पटक थिच्नुहोस्',
  'Silent mode': 'मौन मोड',
  'Nothing is shown on screen. You only feel a short buzz.':
      'स्क्रिनमा केही देखिँदैन। छोटो कम्पन मात्र महसुस हुन्छ।',
  'Without the SMS permission the alert opens your messages app instead of sending silently.':
      'एसएमएस अनुमति बिना सन्देश चुपचाप पठाउनुको सट्टा सन्देश एप खुल्छ।',
  'These triggers work while Sajil Yatra is open on your phone. Working in the background is not built yet. Add emergency contacts first.':
      'यी सुविधा सजिल यात्रा फोनमा खुला हुँदा मात्र चल्छन्। पृष्ठभूमिमा चल्ने सुविधा अहिले बनाइएको छैन। पहिले आपतकालीन सम्पर्कहरू थप्नुहोस्।',
  'Panic alert sent to your emergency contacts.':
      'आपतकालीन सम्पर्कहरूलाई संकेत पठाइयो।',
  'Add an emergency contact so the panic alert has someone to reach.':
      'संकेत पुग्ने कोही हुन आपतकालीन सम्पर्क थप्नुहोस्।',

  // SOS and emergency contacts
  'Emergency contacts': 'आपतकालीन सम्पर्कहरू',
  'Add contact': 'सम्पर्क थप्नुहोस्',
  'Contact name': 'सम्पर्कको नाम',
  'You can save up to 3 contacts.':
      'तपाईंले 3 वटासम्म सम्पर्क सुरक्षित गर्न सक्नुहुन्छ।',
  'No emergency contacts yet.': 'अहिलेसम्म कुनै आपतकालीन सम्पर्क छैन।',
  'Delete': 'हटाउनुहोस्',
  'SOS in {} seconds': '{} सेकेन्डमा एसओएस',
  'Press cancel if this was a mistake.':
      'गल्ती भएमा रद्द गर्नुहोस् थिच्नुहोस्।',
  'Cancel': 'रद्द गर्नुहोस्',
  'Getting your location…': 'तपाईंको स्थान खोज्दै…',
  'SOS alert prepared': 'एसओएस सन्देश तयार भयो',
  'No emergency contacts saved. Add some so they get your location.':
      'कुनै आपतकालीन सम्पर्क सुरक्षित छैन। उनीहरूले तपाईंको स्थान पाउन केही थप्नुहोस्।',
  'Messages opened: press Send in each one.':
      'सन्देश खुलेको छ: पठाउन प्रत्येकमा "पठाउनुहोस्" थिच्नुहोस्।',
  '{} · message opened': '{} · सन्देश खुल्यो',
  '{} · could not open messages': '{} · सन्देश खोल्न सकिएन',
  'Nepal Police (100)': 'नेपाल प्रहरी (100)',
  'Call': 'फोन गर्नुहोस्',
  'Transit dispatch: not connected yet':
      'यातायात डिस्प्याच: अहिले जोडिएको छैन',
  'Location: {}': 'स्थान: {}',
  'Location not available': 'स्थान उपलब्ध छैन',
  'Done': 'सकियो',
  'A Sajil Yatra user': 'सजिल यात्राका एक प्रयोगकर्ता',
  'SOS! {} needs help. Location: {} (sent from Sajil Yatra at {})':
      'एसओएस! {} लाई सहयोग चाहिएको छ। स्थान: {} (सजिल यात्राबाट {} बजे पठाइएको)',
  'SOS! {} needs help. Location not available (sent from Sajil Yatra at {})':
      'एसओएस! {} लाई सहयोग चाहिएको छ। स्थान उपलब्ध छैन (सजिल यात्राबाट {} बजे पठाइएको)',
  'Stuck in traffic': 'ट्राफिकमा अड्किएको',

  // Login with OTP or fingerprint
  'Enter a valid mobile number (starts with 98 or 97)':
      'मान्य मोबाइल नम्बर हाल्नुहोस् (98 वा 97 बाट सुरु हुने)',
  'Enter the code sent to {}': '{} मा पठाइएको कोड हाल्नुहोस्',
  'Apple sign-up is not available yet.':
      'एप्पलबाट साइन अप अहिले उपलब्ध छैन।',
  'Google sign-in did not work. Try again.':
      'गुगल साइन इन काम गरेन। फेरि प्रयास गर्नुहोस्।',
  'Continue with Google': 'गुगलबाट जारी राख्नुहोस्',
  'Google': 'गुगल',
  'Apple': 'एप्पल',
  'Send OTP': 'ओटीपी पठाउनुहोस्',
  'Enter the 6-digit code': '6 अङ्कको कोड हाल्नुहोस्',
  'Verify': 'प्रमाणित गर्नुहोस्',
  'Demo SMS: your Sajil Yatra code is {} (valid for 5 minutes)':
      'डेमो एसएमएस: तपाईंको सजिल यात्रा कोड {} हो (5 मिनेट मान्य)',
  'Resend code in {}s': '{} सेकेन्डमा कोड फेरि पठाउन सकिन्छ',
  'Resend code': 'कोड फेरि पठाउनुहोस्',
  'Change number': 'नम्बर बदल्नुहोस्',
  'This number is not registered. Sign up first.':
      'यो नम्बर दर्ता गरिएको छैन। पहिले साइन अप गर्नुहोस्।',
  'Wrong code. Try again.': 'कोड मिलेन। फेरि प्रयास गर्नुहोस्।',
  'This code has expired. Request a new one.':
      'यो कोडको म्याद सकियो। नयाँ कोड माग्नुहोस्।',
  'Request a new code.': 'नयाँ कोड माग्नुहोस्।',
  'Log in with fingerprint / Face ID':
      'फिंगरप्रिन्ट / फेस आईडीबाट लगइन गर्नुहोस्',
  'Fingerprint did not work. Log in with an OTP instead.':
      'फिंगरप्रिन्ट काम गरेन। बरु ओटीपीबाट लगइन गर्नुहोस्।',
  'Faster login next time?': 'अर्को पटक छिटो लगइन?',
  'Turn on fingerprint / Face ID to log in without waiting for a code.':
      'कोडको पर्खाइ बिना लगइन गर्न फिंगरप्रिन्ट / फेस आईडी खोल्नुहोस्।',
  'Not now': 'अहिले होइन',
  'Enable': 'खोल्नुहोस्',
  'Confirm your fingerprint or face to log in':
      'लगइन गर्न आफ्नो फिंगरप्रिन्ट वा अनुहार पुष्टि गर्नुहोस्',
  'Log out': 'लगआउट',

  // Profile and ID verification
  'My profile': 'मेरो प्रोफाइल',
  'Profile type': 'प्रोफाइलको प्रकार',
  'ID photo': 'परिचयपत्रको फोटो',
  'Take photo': 'फोटो खिच्नुहोस्',
  'Choose photo': 'फोटो छान्नुहोस्',
  'Could not open the photo picker.': 'फोटो छनोट खोल्न सकिएन।',
  'Commuters do not need an ID. Everything is unlocked.':
      'यात्रीलाई परिचयपत्र चाहिँदैन। सबै सुविधा खुला छन्।',
  'Upload a clear photo of your ID to unlock features for this profile.':
      'यो प्रोफाइलका सुविधा खोल्न आफ्नो परिचयपत्रको स्पष्ट फोटो अपलोड गर्नुहोस्।',
  'Your ID is being reviewed. Features for this profile unlock once it is verified.':
      'तपाईंको परिचयपत्र जाँचिँदैछ। प्रमाणित भएपछि यो प्रोफाइलका सुविधा खुल्नेछन्।',
  'Your ID is verified. All features for this profile are unlocked.':
      'तपाईंको परिचयपत्र प्रमाणित भयो। यो प्रोफाइलका सबै सुविधा खुला छन्।',
  'Your ID was rejected. Upload a clearer photo.':
      'तपाईंको परिचयपत्र अस्वीकृत भयो। स्पष्ट फोटो अपलोड गर्नुहोस्।',
  'Not submitted': 'पेश गरिएको छैन',
  'Pending': 'जाँच बाँकी',
  'Verified': 'प्रमाणित',
  'Rejected': 'अस्वीकृत',
  'Choose the Conductor / Driver profile and upload your ID to get verified.':
      'कन्डक्टर / चालक प्रोफाइल छानेर आफ्नो परिचयपत्र अपलोड गर्नुहोस् र प्रमाणित हुनुहोस्।',
  'Verify my ID': 'मेरो परिचयपत्र प्रमाणित गर्नुहोस्',

  // Map
  'Tap a vehicle to follow it': 'पछ्याउन सवारीमा ट्याप गर्नुहोस्',
  'Following {}': '{} पछ्याउँदै',
  'Show details': 'विवरण देखाउनुहोस्',
  'Full-screen map': 'पूरा स्क्रिन नक्सा',
  'Live vehicles': 'प्रत्यक्ष सवारीहरू',
  'Tap a vehicle on the map to follow it. Tap a type to show or hide it.':
      'नक्सामा सवारी पछ्याउन ट्याप गर्नुहोस्। देखाउन वा लुकाउन प्रकारमा ट्याप गर्नुहोस्।',
  'ETA to {}': '{} सम्म पुग्न',
  '{} min': '{} मिनेट',
  '{} km/h': '{} किमी/घण्टा',
  'Stopped': 'रोकिएको',
  'Moving, heading {}': 'चलिरहेको, {} तर्फ',
  'At stop': 'स्टपमा',
  'On the way': 'बाटोमा',
  'Updated just now': 'भर्खरै अद्यावधिक गरियो',
  'Next: {}': 'अर्को: {}',
  'Then {}': 'त्यसपछि {}',
  'Seats: not reported': 'सिट: जानकारी छैन',
  'Seats: {} · updated {}': 'सिट: {} · {} मा अद्यावधिक',
  'Board this': 'यसमा चढ्नुहोस्',
  'Boarding {}': '{} मा चढ्दै',
  'N': 'उत्तर',
  'NE': 'उत्तरपूर्व',
  'E': 'पूर्व',
  'SE': 'दक्षिणपूर्व',
  'S': 'दक्षिण',
  'SW': 'दक्षिणपश्चिम',
  'W': 'पश्चिम',
  'NW': 'उत्तरपश्चिम',

  // Driver shift
  'Driver shift': 'चालक सिफ्ट',
  'Route': 'रुट',
  'Vehicle': 'सवारी',
  'Shift is live': 'सिफ्ट सुरु छ',
  'Since {} · {} updates sent': '{} देखि · {} अपडेट पठाइयो',
  'Waiting for GPS…': 'जीपीएस पर्खँदै…',
  'How full is the vehicle?': 'सवारी कति भरिएको छ?',
  'Start shift': 'सिफ्ट सुरु गर्नुहोस्',
  'End shift': 'सिफ्ट अन्त्य गर्नुहोस्',
  'End your shift before leaving.': 'बाहिर जानुअघि आफ्नो सिफ्ट अन्त्य गर्नुहोस्।',
  'Only verified conductors can start a shift.':
      'प्रमाणित कन्डक्टरले मात्र सिफ्ट सुरु गर्न सक्छन्।',
  'Lost the GPS signal. Check that location is on.':
      'जीपीएस सिग्नल गयो। लोकेसन खुला छ कि जाँच गर्नुहोस्।',
  'Turn on location (GPS) to start your shift.':
      'सिफ्ट सुरु गर्न लोकेसन (जीपीएस) खोल्नुहोस्।',
  'Allow location access to start your shift.':
      'सिफ्ट सुरु गर्न लोकेसन पहुँचको अनुमति दिनुहोस्।',
  'Sajil Yatra shift active': 'सजिल यात्रा सिफ्ट सक्रिय',
  'Your vehicle location is being shared.':
      'तपाईंको सवारीको स्थान साझा हुँदैछ।',

  // Vehicle types and seat status
  'Big Bus': 'ठूलो बस',
  'Microbus': 'माइक्रोबस',
  'Safa Tempo': 'सफा टेम्पो',
  'Empty': 'खाली',
  'Standing': 'उभिएर',
  'Packed': 'खचाखच',

  // Places, vehicles and operators
  'Kalanki': 'कलंकी',
  'Kalimati': 'कालिमाटी',
  'Tripureshwor': 'त्रिपुरेश्वर',
  'Thapathali': 'थापाथली',
  'Maitighar': 'माइतीघर',
  'Baneshwor': 'बानेश्वर',
  'Koteshwor': 'कोटेश्वर',
  'Ratnapark': 'रत्नपार्क',
  'Bhaktapur': 'भक्तपुर',
  'Micro 12': 'माइक्रो 12',
  'Micro 5': 'माइक्रो 5',
  'Bus 21': 'बस 21',
  'Tempo 7': 'टेम्पो 7',
  'Safa Tempo 4': 'सफा टेम्पो 4',
  'Ba 2 Kha 4471': 'बा 2 ख 4471',
  'Ba 1 Kha 2210': 'बा 1 ख 2210',
  'Ba 3 Kha 1102': 'बा 3 ख 1102',
  'Ba 4 Pa 7788': 'बा 4 प 7788',
  'Ba 3 Cha 1187': 'बा 3 च 1187',
  'Nepal Yatayat Samiti': 'नेपाल यातायात समिति',
  'Sajha Yatayat': 'साझा यातायात',
  'Safa Tempo Committee': 'सफा टेम्पो समिति',
};
