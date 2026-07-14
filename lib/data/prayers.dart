import '../models/prayer_content.dart';

const prayers = <PrayerContent>[
  PrayerContent(
    day: 1,
    title: 'Come and Rest',
    scriptureReference: 'Matthew 11:28–30',
    scriptureText:
        '“Come to me, all you who labor and are heavily burdened, and I will give you rest. Take my yoke upon you and learn from me, for I am gentle and humble in heart; and you will find rest for your souls. For my yoke is easy, and my burden is light.”',
    preparationText:
        'Take a slow breath in. As you gently breathe out, allow yourself to become still. Let the noise of the day begin to fade. There is nothing you need to solve right now.',
    reflectionText:
        'You have carried enough for today. I see the burdens you show to others, and I also see the ones you carry quietly. You do not need perfect words before coming to me. Bring me what has made you tired. Stay here with me, and allow yourself to rest. You are not alone.',
    responsePrayer:
        'Jesus, I give you what I cannot carry today. Quiet my heart. Renew my strength. Help me trust that I am not alone.',
    closingText: 'Rest here for a moment. Amen.',
    audioUrl: 'https://example.invalid/day_001.m4a',
    estimatedDuration: Duration(minutes: 2),
    hasProductionAudio: true,
    sections: [
      PrayerSection(
        type: PrayerSectionType.preparation,
        label: 'Be still',
        text:
            'Take a slow breath in. As you gently breathe out, allow yourself to become still.',
        startsAt: Duration.zero,
      ),
      PrayerSection(
        type: PrayerSectionType.scripture,
        label: 'Scripture',
        text:
            'Come to me, all you who labor and are heavily burdened, and I will give you rest.',
        startsAt: Duration(seconds: 20),
      ),
      PrayerSection(
        type: PrayerSectionType.reflection,
        label: 'Jesus speaks',
        text:
            'You have carried enough for today. I see the burdens you show to others, and I also see the ones you carry quietly. You do not need perfect words before coming to me. Stay here with me, and allow yourself to rest. You are not alone.',
        startsAt: Duration(seconds: 31),
      ),
      PrayerSection(
        type: PrayerSectionType.response,
        label: 'Your prayer',
        text:
            'Jesus, I give you what I cannot carry today. Quiet my heart. Renew my strength. Help me trust that I am not alone.',
        startsAt: Duration(seconds: 58),
      ),
      PrayerSection(
        type: PrayerSectionType.closing,
        label: 'Amen',
        text: 'Rest here for a moment. Amen.',
        startsAt: Duration(seconds: 66),
      ),
    ],
  ),
  PrayerContent(
    day: 2,
    title: 'My Peace for You',
    scriptureReference: 'John 14:27',
    scriptureText:
        '“Peace I leave with you. My peace I give to you; not as the world gives, I give to you. Don’t let your heart be troubled, neither let it be fearful.”',
    preparationText:
        'Let your shoulders soften. Take one slow breath, and make room for peace.',
    reflectionText:
        'The peace I give you does not depend on everything going well. It can meet you in uncertainty and stay with you when answers have not yet come. Let your heart rest in my presence today.',
    responsePrayer:
        'Jesus, receive what troubles me. Teach me to live from your peace instead of my fear.',
    closingText: 'Carry my peace with you. Amen.',
    audioUrl: 'https://example.invalid/day_002.m4a',
    estimatedDuration: Duration(minutes: 2),
    hasProductionAudio: true,
    sections: [
      PrayerSection(
        type: PrayerSectionType.preparation,
        label: 'Be still',
        text: 'Let your shoulders soften. Take one slow breath.',
        startsAt: Duration.zero,
      ),
      PrayerSection(
        type: PrayerSectionType.scripture,
        label: 'Scripture',
        text:
            'Peace I leave with you. My peace I give to you. Don’t let your heart be troubled, neither let it be fearful.',
        startsAt: Duration(seconds: 18),
      ),
      PrayerSection(
        type: PrayerSectionType.reflection,
        label: 'Jesus speaks',
        text:
            'The peace I give you does not depend on everything going well. Let your heart rest in my presence today.',
        startsAt: Duration(seconds: 32),
      ),
      PrayerSection(
        type: PrayerSectionType.response,
        label: 'Your prayer',
        text:
            'Jesus, receive what troubles me. Teach me to live from your peace instead of my fear.',
        startsAt: Duration(seconds: 67),
      ),
      PrayerSection(
        type: PrayerSectionType.closing,
        label: 'Amen',
        text: 'Carry my peace with you. Amen.',
        startsAt: Duration(seconds: 84),
      ),
    ],
  ),
  PrayerContent(
    day: 3,
    title: 'Remain in Me',
    scriptureReference: 'John 15:4–5',
    scriptureText:
        '“Remain in me, and I in you. As the branch can’t bear fruit by itself unless it remains in the vine, so neither can you, unless you remain in me. I am the vine. You are the branches.”',
    preparationText:
        'Breathe slowly. Release the need to hurry, and become present to this moment.',
    reflectionText:
        'You do not have to produce a faithful life through effort alone. Stay close to me. Let your choices, your work, and your love grow from our life together. Begin today by remaining here.',
    responsePrayer:
        'Jesus, keep me close to you. Let my life grow from your love and not from anxious striving.',
    closingText: 'Remain in my love. Amen.',
    audioUrl: 'https://example.invalid/day_003.m4a',
    estimatedDuration: Duration(minutes: 2),
    hasProductionAudio: true,
    sections: [
      PrayerSection(
        type: PrayerSectionType.preparation,
        label: 'Be still',
        text: 'Breathe slowly. Release the need to hurry.',
        startsAt: Duration.zero,
      ),
      PrayerSection(
        type: PrayerSectionType.scripture,
        label: 'Scripture',
        text:
            'Remain in me, and I in you. I am the vine. You are the branches.',
        startsAt: Duration(seconds: 18),
      ),
      PrayerSection(
        type: PrayerSectionType.reflection,
        label: 'Jesus speaks',
        text:
            'You do not have to produce a faithful life through effort alone. Stay close to me.',
        startsAt: Duration(seconds: 32),
      ),
      PrayerSection(
        type: PrayerSectionType.response,
        label: 'Your prayer',
        text:
            'Jesus, keep me close to you. Let my life grow from your love and not from anxious striving.',
        startsAt: Duration(seconds: 67),
      ),
      PrayerSection(
        type: PrayerSectionType.closing,
        label: 'Amen',
        text: 'Remain in my love. Amen.',
        startsAt: Duration(seconds: 84),
      ),
    ],
  ),
  PrayerContent(
    day: 4,
    title: 'I Have Called You by Name',
    scriptureReference: 'Isaiah 43:1–2',
    scriptureText:
        '“Don’t be afraid, for I have redeemed you. I have called you by your name. You are mine. When you pass through the waters, I will be with you.”',
    preparationText:
        'Take a slow breath. Let yourself be known here, without pretending or performing.',
    reflectionText:
        'You are not defined by your fears, your failures, or the demands placed upon you. I have called you by name, and you belong to me. Whatever this day holds, you will not face it alone. My presence is with you in deep waters and on ordinary ground. You can move through today as someone held, not as someone forgotten.',
    responsePrayer:
        'Jesus, remind me that I belong to you. Give me courage for what I face, and help me notice your presence with me.',
    closingText: 'You are mine. Walk in peace. Amen.',
    audioUrl: 'https://example.invalid/day_004.m4a',
    estimatedDuration: Duration(minutes: 2),
    hasProductionAudio: true,
    sections: [
      PrayerSection(
        type: PrayerSectionType.preparation,
        label: 'Be still',
        text: 'Take a slow breath. Let yourself be known here.',
        startsAt: Duration.zero,
      ),
      PrayerSection(
        type: PrayerSectionType.scripture,
        label: 'Scripture',
        text: 'I have called you by your name. You are mine.',
        startsAt: Duration(seconds: 18),
      ),
      PrayerSection(
        type: PrayerSectionType.reflection,
        label: 'Jesus speaks',
        text:
            'You are not defined by your fears, your failures, or the demands placed upon you. I have called you by name, and you belong to me. Whatever this day holds, you will not face it alone.',
        startsAt: Duration(seconds: 32),
      ),
      PrayerSection(
        type: PrayerSectionType.response,
        label: 'Your prayer',
        text:
            'Jesus, remind me that I belong to you. Give me courage for what I face, and help me notice your presence with me.',
        startsAt: Duration(seconds: 67),
      ),
      PrayerSection(
        type: PrayerSectionType.closing,
        label: 'Amen',
        text: 'You are mine. Walk in peace. Amen.',
        startsAt: Duration(seconds: 84),
      ),
    ],
  ),
  PrayerContent(
    day: 5,
    title: 'A Life That Grows',
    scriptureReference: 'Romans 12:1–2',
    scriptureText:
        '“Therefore I urge you, brothers, by the mercies of God, to present your bodies a living sacrifice, holy, acceptable to God, which is your spiritual service. Don’t be conformed to this world, but be transformed by the renewing of your mind, so that you may prove what is the good, well-pleasing, and perfect will of God.”',
    preparationText:
        'Become present to this moment. Ask God to show you one small step of love today.',
    reflectionText:
        'A changed life rarely begins with one dramatic moment. It grows through small choices made with an open heart. Let me renew the way you see yourself, other people, and the day in front of you. You do not have to become someone else. As you stay close to me, I will shape your life into something more loving, more honest, and more free.',
    responsePrayer:
        'Jesus, renew my mind and shape my choices today. Show me one small way to love you and the people around me.',
    closingText: 'Take the next faithful step. Amen.',
    audioUrl: 'https://example.invalid/day_005.m4a',
    estimatedDuration: Duration(minutes: 2),
    sections: [
      PrayerSection(
        type: PrayerSectionType.preparation,
        label: 'Be present',
        text: 'Become present to this moment.',
        startsAt: Duration.zero,
      ),
      PrayerSection(
        type: PrayerSectionType.scripture,
        label: 'Scripture',
        text:
            'Therefore I urge you, brothers, by the mercies of God, to present your bodies a living sacrifice, holy, acceptable to God, which is your spiritual service. Don’t be conformed to this world, but be transformed by the renewing of your mind, so that you may prove what is the good, well-pleasing, and perfect will of God.',
        startsAt: Duration(seconds: 18),
      ),
      PrayerSection(
        type: PrayerSectionType.reflection,
        label: 'Jesus speaks',
        text:
            'A changed life rarely begins with one dramatic moment. It grows through small choices made with an open heart. As you stay close to me, I will shape your life into something more loving, more honest, and more free.',
        startsAt: Duration(seconds: 32),
      ),
      PrayerSection(
        type: PrayerSectionType.response,
        label: 'Your prayer',
        text:
            'Jesus, renew my mind and shape my choices today. Show me one small way to love you and the people around me.',
        startsAt: Duration(seconds: 67),
      ),
      PrayerSection(
        type: PrayerSectionType.closing,
        label: 'Amen',
        text: 'Take the next faithful step. Amen.',
        startsAt: Duration(seconds: 84),
      ),
    ],
  ),
  PrayerContent(
    day: 6,
    title: 'Love God and Your Neighbor',
    scriptureReference: 'Luke 10:27',
    scriptureText:
        '“You shall love the Lord your God with all your heart, with all your soul, with all your strength, and with all your mind; and your neighbor as yourself.”',
    preparationText:
        'Become still for a moment. Receive the love of God before thinking about what you need to do.',
    reflectionText:
        'Love begins by staying close to me, then allowing that love to reach the person in front of you. You do not need a grand gesture. Offer your attention, your patience, or one small act of kindness. Let love become practical today.',
    responsePrayer:
        'Jesus, teach me to love you with my whole life and to love the people around me with patience, courage, and kindness.',
    closingText: 'Go and let love become visible. Amen.',
    audioUrl: 'https://example.invalid/day_006.m4a',
    estimatedDuration: Duration(minutes: 2),
    hasProductionAudio: true,
    sections: [
      PrayerSection(
        type: PrayerSectionType.preparation,
        label: 'Be present',
        text: 'Become still for a moment. Receive the love of God.',
        startsAt: Duration.zero,
      ),
      PrayerSection(
        type: PrayerSectionType.scripture,
        label: 'Scripture',
        text:
            'Love the Lord your God with your whole being, and love your neighbor as yourself.',
        startsAt: Duration(seconds: 18),
      ),
      PrayerSection(
        type: PrayerSectionType.reflection,
        label: 'Jesus speaks',
        text:
            'Love begins by staying close to me, then allowing that love to reach the person in front of you.',
        startsAt: Duration(seconds: 32),
      ),
      PrayerSection(
        type: PrayerSectionType.response,
        label: 'Your prayer',
        text:
            'Jesus, teach me to love you with my whole life and to love the people around me well.',
        startsAt: Duration(seconds: 67),
      ),
      PrayerSection(
        type: PrayerSectionType.closing,
        label: 'Amen',
        text: 'Go and let love become visible. Amen.',
        startsAt: Duration(seconds: 84),
      ),
    ],
  ),
  PrayerContent(
    day: 7,
    title: 'The Joy of Giving',
    scriptureReference: '2 Corinthians 9:6–8',
    scriptureText:
        '“Remember this: he who sows sparingly will also reap sparingly. He who sows bountifully will also reap bountifully. Let each man give according as he has determined in his heart, not grudgingly or under compulsion, for God loves a cheerful giver. And God is able to make all grace abound to you, that you, always having all sufficiency in everything, may abound to every good work.”',
    preparationText:
        'Open your heart to generosity. Receive God’s grace before deciding what you can give.',
    reflectionText:
        'Generosity is not a bargain with God or a way to prove your worth. Give freely, wisely, and without pressure. Trust that God’s grace will provide what you need to keep doing good, and let one act of love become a source of joy and thanksgiving.',
    responsePrayer:
        'Jesus, free me from fear and compulsion. Teach me to give wisely, freely, and joyfully, trusting your grace to guide me.',
    closingText: 'Give with joy, and remain open to God’s care. Amen.',
    audioUrl: 'https://example.invalid/day_007.m4a',
    estimatedDuration: Duration(minutes: 2),
    hasProductionAudio: true,
    sections: [
      PrayerSection(
        type: PrayerSectionType.preparation,
        label: 'Open your heart',
        text: 'Receive God’s grace before deciding what you can give.',
        startsAt: Duration.zero,
      ),
      PrayerSection(
        type: PrayerSectionType.scripture,
        label: 'Scripture',
        text:
            'Give as you have determined in your heart, not grudgingly or under compulsion, for God loves a cheerful giver.',
        startsAt: Duration(seconds: 18),
      ),
      PrayerSection(
        type: PrayerSectionType.reflection,
        label: 'Jesus speaks',
        text:
            'Generosity is not a bargain or a burden. Give freely and let grace shape the good you can do.',
        startsAt: Duration(seconds: 32),
      ),
      PrayerSection(
        type: PrayerSectionType.response,
        label: 'Your prayer',
        text: 'Jesus, teach me to give wisely, freely, and joyfully.',
        startsAt: Duration(seconds: 67),
      ),
      PrayerSection(
        type: PrayerSectionType.closing,
        label: 'Amen',
        text: 'Give with joy, and remain open to God’s care. Amen.',
        startsAt: Duration(seconds: 84),
      ),
    ],
  ),
];
