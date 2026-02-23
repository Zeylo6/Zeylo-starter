import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color kPurple = Color(0xFF914BCF);
const Color kLight = Color(0xFFF2E9FB);
const Color kDeepNavy = Color(0xFF1A2048);

enum SceneType { explore, community, booking, hiking, photography, food, map, completed, cooking }

void main() => runApp(const ZeyloApp());

class ZeyloApp extends StatelessWidget {
  const ZeyloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zeylo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPurple),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _TechPageTransitionsBuilder(),
            TargetPlatform.iOS: _TechPageTransitionsBuilder(),
            TargetPlatform.macOS: _TechPageTransitionsBuilder(),
            TargetPlatform.windows: _TechPageTransitionsBuilder(),
            TargetPlatform.linux: _TechPageTransitionsBuilder(),
          },
        ),
      ),
      builder: (context, child) => ScrollConfiguration(
        behavior: const _SmoothScrollBehavior(),
        child: child ?? const SizedBox.shrink(),
      ),
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/app': (_) => const MainShell(),
        '/booking': (_) => const BookingScreen(),
        '/complete': (_) => const CompletedScreen(),
        '/rate': (_) => const RateScreen(),
        '/dashboard': (_) => const HostDashboardScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1100), () => Navigator.pushReplacementNamed(context, '/onboarding'));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: kPurple, body: Center(child: Text('Z', style: TextStyle(fontSize: 120, color: Colors.white, fontWeight: FontWeight.w900))));
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _c = PageController();
  int i = 0;
  double _bgShift = 0;
  final slides = const [
    ('Welcome to Zeylo', 'Discover local experiences that match your mood'),
    ('Hello from Zeylo', 'Connect with people, businesses, and hosts nearby'),
    ('Plan in Seconds', 'Book and host instantly with secure flows'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const AppBackButton(),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/app'),
                    child: const Text('Skip'),
                  ),
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      left: -80 + (_bgShift * 40),
                      top: 20,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [Color(0x22FFFFFF), Color(0x00FFFFFF)]),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      right: -60 + (_bgShift * -30),
                      bottom: 40,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)]),
                        ),
                      ),
                    ),
                    PageView.builder(
                      controller: _c,
                      onPageChanged: (v) => setState(() {
                        i = v;
                        _bgShift = v.toDouble();
                      }),
                      itemCount: slides.length,
                      itemBuilder: (_, idx) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 450),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: SceneImage(
                            key: ValueKey(idx),
                            width: 240,
                            height: 220,
                            borderRadius: BorderRadius.circular(16),
                            title: slides[idx].$1,
                            subtitle: slides[idx].$2,
                            scene: [SceneType.explore, SceneType.community, SceneType.booking][idx],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 450),
                          child: Text(
                            slides[idx].$1,
                            key: ValueKey('title$idx'),
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 450),
                          child: Text(
                            slides[idx].$2,
                            key: ValueKey('sub$idx'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (d) => Container(width: 8, height: 8, margin: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, color: d == i ? kPurple : const Color(0xFFD9C5ED))))),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: kPurple, minimumSize: const Size.fromHeight(50)),
                onPressed: () => Navigator.pushReplacementNamed(context, '/app'),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)), onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text('Log In')),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => AuthScreen(title: 'Log in', primary: 'Log in', prompt: 'New to Zeylo?', action: 'Create Account', onAction: () => Navigator.pushReplacementNamed(context, '/signup'));
}

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});
  @override
  Widget build(BuildContext context) => AuthScreen(title: 'Create Account', primary: 'Create Account', prompt: 'Already have an account?', action: 'Log In', onAction: () => Navigator.pushReplacementNamed(context, '/login'));
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.title, required this.primary, required this.prompt, required this.action, required this.onAction});
  final String title;
  final String primary;
  final String prompt;
  final String action;
  final VoidCallback onAction;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool hide = true;
  bool agree = false;
  bool _phoneTouched = false;
  bool _phoneValid = false;
  String? _phoneError;
  final TextEditingController _phoneController = TextEditingController();
  bool _emailTouched = false;
  bool _emailValid = false;
  String? _emailError;
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    if (!_phoneTouched) {
      _phoneTouched = true;
    }
    final error = _phoneValidationError(value, touched: _phoneTouched);
    setState(() {
      _phoneError = error;
      _phoneValid = error == null && value.isNotEmpty;
    });
  }

  void _onEmailChanged(String value) {
    if (!_emailTouched) {
      _emailTouched = true;
    }
    final error = _emailValidationError(value, touched: _emailTouched);
    setState(() {
      _emailError = error;
      _emailValid = error == null && value.isNotEmpty;
    });
  }

  String? _phoneValidationError(String value, {required bool touched}) {
    if (!touched && value.isEmpty) return null;
    if (value.isEmpty) return 'Mobile number is required';
    if (!value.startsWith('07')) return 'Must start with 07';
    if (value.length != 10) return 'Must be 10 digits';
    return null;
  }

  String? _emailValidationError(String value, {required bool touched}) {
    if (!touched && value.isEmpty) return null;
    if (value.isEmpty) return 'Email is required';
    const pattern = r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$';
    final isValid = RegExp(pattern).hasMatch(value);
    if (!isValid) return 'Enter a valid email';
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AuthBackdrop(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              children: [
                Row(
                  children: [
                    const AppBackButton(),
                    const Spacer(),
                    Text(widget.title.toUpperCase(), style: const TextStyle(color: kPurple, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text('Let’s set up your account in seconds.', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      const Field(label: 'Full Name', hint: 'Enter your full name'),
                      Field(
                        label: 'Email Address',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: _onEmailChanged,
                        errorText: _emailError,
                      ),
                      Field(
                        label: 'Phone Number',
                        hint: '07X XXX XXXX',
                        prefix: 'LK | ',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                        onChanged: _onPhoneChanged,
                        errorText: _phoneError,
                      ),
                      Field(
                        label: 'Password',
                        hint: 'Create a password',
                        obscure: hide,
                        suffix: IconButton(onPressed: () => setState(() => hide = !hide), icon: Icon(hide ? Icons.visibility_off : Icons.visibility)),
                      ),
                      Row(
                        children: [
                          Checkbox(value: agree, onChanged: (v) => setState(() => agree = v ?? false)),
                          const Expanded(child: Text('I agree to the Terms of Service and Privacy Policy', style: TextStyle(color: Colors.black54))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: kPurple, minimumSize: const Size.fromHeight(48)),
                        onPressed: agree && _phoneValid && _emailValid ? () => Navigator.pushNamedAndRemoveUntil(context, '/app', (_) => false) : null,
                        child: Text(widget.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: GestureDetector(
                    onTap: widget.onAction,
                    child: Text('${widget.prompt} ${widget.action}', style: const TextStyle(color: kPurple, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int idx = 0;
  final List<int> _tabHistory = [];

  void _selectTab(int next) {
    if (next == idx) return;
    _tabHistory.remove(next);
    _tabHistory.add(idx);
    setState(() => idx = next);
  }

  void _backToPreviousTab() {
    if (_tabHistory.isEmpty) {
      if (idx != 0) {
        setState(() => idx = 0);
      }
      return;
    }
    final prev = _tabHistory.removeLast();
    setState(() => idx = prev);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      DiscoverTab(onBack: _backToPreviousTab),
      NearbyTab(onBack: _backToPreviousTab),
      MysteryTab(onBack: _backToPreviousTab),
      ProfileTab(onBack: _backToPreviousTab),
    ];
    return PopScope(
      canPop: idx == 0 && _tabHistory.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _backToPreviousTab();
      },
      child: Scaffold(
        body: tabs[idx],
        bottomNavigationBar: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: ''),
            NavigationDestination(icon: Icon(Icons.auto_awesome), label: ''),
            NavigationDestination(icon: Icon(Icons.hub), label: ''),
            NavigationDestination(icon: Icon(Icons.flag_outlined), label: ''),
          ],
        ),
      ),
    );
  }
}

class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(onPressed: onBack),
        title: const Text('ZEYLO', style: TextStyle(color: kPurple, fontWeight: FontWeight.w900, fontSize: 28)),
        actions: [IconButton(onPressed: () => Navigator.pushNamed(context, '/dashboard'), icon: const Icon(Icons.person, color: kPurple))],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SceneImage(
          height: 180,
          margin: const EdgeInsets.only(bottom: 14),
          borderRadius: BorderRadius.circular(20),
          title: 'This Weekend',
          subtitle: 'Find your next vibe in Colombo',
          scene: SceneType.explore,
        ),
        const Wrap(spacing: 8, children: [Chip(label: Text('Popular')), Chip(label: Text('Nearby')), Chip(label: Text('Top Rated')), Chip(label: Text('New'))]),
        const SizedBox(height: 12),
        ExperienceCard(scene: SceneType.hiking, title: 'Hanthana Hiking Adventure', host: 'Hashan Perera', location: 'Hanthana, Kandy', desc: 'Join a sunrise hike through Hanthana mountain range.', onBook: () => Navigator.pushNamed(context, '/booking')),
        ExperienceCard(scene: SceneType.photography, title: 'Sunset Photography Workshop', host: 'Sahan De Silva', location: 'Colombo 05', desc: 'Late-evening mini coffee rave with live DJs.', onBook: () => Navigator.pushNamed(context, '/booking')),
        ExperienceCard(scene: SceneType.food, title: 'Street Food Night Walk', host: 'Maya Fernando', location: 'Pettah, Colombo', desc: 'Taste iconic local bites and hidden food stalls.', onBook: () => Navigator.pushNamed(context, '/booking')),
      ]),
    );
  }
}

class NearbyTab extends StatelessWidget {
  const NearbyTab({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: AppBackButton(onPressed: onBack), title: const Text('Colombo 05, Sri Lanka')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        SceneImage(
          height: 210,
          borderRadius: BorderRadius.circular(12),
          title: 'Nearby hotspots',
          subtitle: 'Places and events around Colombo 05',
          scene: SceneType.map,
          child: Center(child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: kPurple), onPressed: () => Navigator.pushNamed(context, '/complete'), icon: const Icon(Icons.place), label: const Text('Open Map'))),
        ),
        const SizedBox(height: 10),
        const NearbyItem(title: 'Rooftop Party Tonight', subtitle: '0.3 miles * 8:00 PM * 12 going', action: 'Join'),
        const NearbyItem(title: 'Emma wants company', subtitle: 'Mission District * 0.5 miles', action: 'Connect'),
        const NearbyItem(title: 'Luna Coffee Roasters', subtitle: 'Local cafe * 0.2 miles * 4.8', action: 'Visit'),
      ]),
    );
  }
}

class MysteryTab extends StatelessWidget {
  const MysteryTab({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: AppBackButton(onPressed: onBack), title: const Text('Mystery Experience')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const CircleAvatar(radius: 34, backgroundColor: kPurple, child: Text('?', style: TextStyle(color: Colors.white, fontSize: 28))),
        const SizedBox(height: 8),
        const Text('Create Your Mystery', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        const Field(label: 'Location', hint: 'Enter city or area'),
        const Field(label: 'Date', hint: 'mm/yyyy'),
        const Field(label: 'Time', hint: 'Morning'),
        const Field(label: 'Experience Type', hint: 'Adventure / Food / Arts'),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: kPurple), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mystery experience created'))), child: const Text('Create')),
      ]),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: AppBackButton(onPressed: onBack), title: const Text('Alex Johnson')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 32, child: Icon(Icons.person)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Alex Johnson', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _ProfileStat(value: '234', label: 'followers')),
                      Expanded(child: _ProfileStat(value: '189', label: 'following')),
                      Expanded(child: _ProfileStat(value: '02', label: 'posts')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: kPurple, minimumSize: const Size.fromHeight(48)),
          onPressed: () {},
          child: const Text('Follow'),
        ),
        const SizedBox(height: 16),
        const Text('Past Experiences', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (_, index) => SceneImage(
                width: 240,
                height: 160,
                borderRadius: BorderRadius.circular(14),
                scene: [SceneType.hiking, SceneType.food, SceneType.cooking][index],
                title: ['Mountain Trail', 'Street Bites', 'Cooking Class'][index],
                subtitle: ['Nature', 'Food', 'Culture'][index],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const NearbyItem(title: 'Traditional Cooking Adventure', subtitle: 'USD 45/person', action: 'View'),
        const NearbyItem(title: 'Street Food Adventure', subtitle: 'USD 45/person', action: 'View'),
        const SizedBox(height: 14),
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
          onPressed: () => Navigator.pushNamed(context, '/dashboard'),
          child: const Text('Host Dashboard'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
          child: const Text('Log Out'),
        ),
      ]),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _phoneTouched = false;
  bool _phoneValid = false;
  String? _phoneError;
  final TextEditingController _phoneController = TextEditingController();

  bool _emailTouched = false;
  bool _emailValid = false;
  String? _emailError;
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    if (!_phoneTouched) {
      _phoneTouched = true;
    }
    final error = _phoneValidationError(value, touched: _phoneTouched);
    setState(() {
      _phoneError = error;
      _phoneValid = error == null && value.isNotEmpty;
    });
  }

  void _onEmailChanged(String value) {
    if (!_emailTouched) {
      _emailTouched = true;
    }
    final error = _emailValidationError(value, touched: _emailTouched);
    setState(() {
      _emailError = error;
      _emailValid = error == null && value.isNotEmpty;
    });
  }

  String? _phoneValidationError(String value, {required bool touched}) {
    if (!touched && value.isEmpty) return null;
    if (value.isEmpty) return 'Mobile number is required';
    if (!value.startsWith('07')) return 'Must start with 07';
    if (value.length != 10) return 'Must be 10 digits';
    return null;
  }

  String? _emailValidationError(String value, {required bool touched}) {
    if (!touched && value.isEmpty) return null;
    if (value.isEmpty) return 'Email is required';
    const pattern = r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$';
    final isValid = RegExp(pattern).hasMatch(value);
    if (!isValid) return 'Enter a valid email';
    return null;
  }

  bool get _canConfirm => _phoneValid && _emailValid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: const Text('Complete Your Booking')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Field(label: 'Full Name', hint: 'Enter your full name'),
        Field(
          label: 'Email Address',
          hint: 'Enter your email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: _onEmailChanged,
          errorText: _emailError,
        ),
        Field(
          label: 'Phone Number',
          hint: '07X XXX XXXX',
          prefix: 'LK | ',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          onChanged: _onPhoneChanged,
          errorText: _phoneError,
        ),
        const Field(label: 'Guests', hint: '1 Guest'),
        const Field(label: 'Date', hint: 'mm/dd/yyyy'),
        const Field(label: 'Time', hint: '9:00 AM'),
        const Divider(),
        const Field(label: 'Card Number', hint: 'XXXX XXXX XXXX XXXX'),
        const Field(label: 'Expiry Date', hint: 'mm/yyyy'),
        const Field(label: 'CVC', hint: '123'),
      ]),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: kPurple, minimumSize: const Size.fromHeight(48)),
          onPressed: _canConfirm ? () => Navigator.pushNamed(context, '/complete') : null,
          child: const Text('Confirm Booking'),
        ),
      ),
    );
  }
}

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Align(alignment: Alignment.centerLeft, child: AppBackButton()),
              const SizedBox(height: 30),
              const CircleAvatar(radius: 34, backgroundColor: kLight, child: Icon(Icons.check, color: kPurple, size: 34)),
              const SizedBox(height: 12),
              const Text('Completed!', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: kPurple)),
              const Text('Your host has ended the session.', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 20),
              const SceneImage(
                height: 120,
                borderRadius: BorderRadius.all(Radius.circular(14)),
                title: 'Session Completed',
                subtitle: 'Wrapping up and processing payment',
                scene: SceneType.completed,
              ),
              const Spacer(),
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 10), Text('Processing payment automatically...')]),
              const SizedBox(height: 14),
              FilledButton(style: FilledButton.styleFrom(backgroundColor: kPurple, minimumSize: const Size.fromHeight(48)), onPressed: () => Navigator.pushNamed(context, '/rate'), child: const Text('Continue')),
            ],
          ),
        ),
      ),
    );
  }
}

class RateScreen extends StatefulWidget {
  const RateScreen({super.key});
  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int stars = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton()),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const CircleAvatar(radius: 35, child: Icon(Icons.person)),
          const SizedBox(height: 10),
          const Text('Rate Shenuka', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
          const Text('How was your Sunset Kayaking?', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (x) => IconButton(onPressed: () => setState(() => stars = x + 1), icon: Icon(x < stars ? Icons.star : Icons.star_border, color: kPurple)))),
          const TextField(maxLines: 5, decoration: InputDecoration(hintText: 'Share your experience...', border: OutlineInputBorder())),
          const Spacer(),
          Row(children: [
            TextButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/app', (_) => false), child: const Text('Skip')),
            const Spacer(),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: kPurple), onPressed: stars == 0 ? null : () => Navigator.pushNamedAndRemoveUntil(context, '/app', (_) => false), child: const Text('Submit')),
          ])
        ]),
      ),
    );
  }
}

class HostDashboardScreen extends StatelessWidget {
  const HostDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      body: SafeArea(
        child: ListView(children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, top: 8),
            child: Align(alignment: Alignment.centerLeft, child: AppBackButton()),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [kPurple, Color(0xFFB385E1)])),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [CircleAvatar(backgroundColor: Color(0x44FFFFFF), child: Icon(Icons.person, color: Colors.white)), SizedBox(width: 10), Text('Sarah Martinez\\nSuperhost', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
              SizedBox(height: 12),
              Row(children: [Expanded(child: DashStat(value: 'USD 3,240', label: 'This Month')), SizedBox(width: 8), Expanded(child: DashStat(value: '4.9', label: 'Avg Rating')), SizedBox(width: 8), Expanded(child: DashStat(value: '142', label: 'Bookings'))]),
            ]),
          ),
          const Panel(title: 'Profile Completion', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Progress'), Text('85%', style: TextStyle(color: kPurple, fontWeight: FontWeight.w700))]), SizedBox(height: 8), LinearProgressIndicator(value: 0.85, color: kPurple), SizedBox(height: 8), Text('Add 2 more photos to reach 100%', style: TextStyle(color: Colors.black54))])),
          const Panel(title: 'Performance', child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Response Rate'), Text('98%', style: TextStyle(fontWeight: FontWeight.w700))]), SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Acceptance Rate'), Text('92%', style: TextStyle(fontWeight: FontWeight.w700))]), SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total Bookings'), Text('142', style: TextStyle(fontWeight: FontWeight.w700))])])),
          Panel(title: 'Active Experiences', child: Column(children: [const NearbyItem(title: 'Surfing in Weligama', subtitle: 'Open listing', action: 'Edit'), const NearbyItem(title: 'Sunrise watching', subtitle: 'Open listing', action: 'Edit'), const NearbyItem(title: 'Traditional Cooking', subtitle: 'Open listing', action: 'Edit'), TextButton(onPressed: () {}, child: const Text('+ Create New Experience', style: TextStyle(color: kPurple)))])),
        ]),
      ),
    );
  }
}

class SceneImage extends StatelessWidget {
  const SceneImage({
    super.key,
    required this.scene,
    this.title,
    this.subtitle,
    this.height = 180,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.margin,
    this.child,
  });

  final SceneType scene;
  final String? title;
  final String? subtitle;
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? margin;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final spec = _sceneSpec(scene);
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: spec.colors),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 14, offset: Offset(0, 8))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -14,
            top: -10,
            child: Icon(spec.mainIcon, size: 120, color: Colors.white24),
          ),
          Positioned(
            left: 12,
            top: 14,
            child: Row(
              children: [
                Icon(spec.accentIcon, color: Colors.white, size: 22),
                const SizedBox(width: 6),
                Text(spec.tag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (title != null || subtitle != null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) Text(title!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  if (subtitle != null) Text(subtitle!, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          // ignore: use_null_aware_elements
          if (child case final overlayChild?) overlayChild,
        ],
      ),
    );
  }
}

class _SceneSpec {
  const _SceneSpec({required this.colors, required this.mainIcon, required this.accentIcon, required this.tag});
  final List<Color> colors;
  final IconData mainIcon;
  final IconData accentIcon;
  final String tag;
}

_SceneSpec _sceneSpec(SceneType scene) {
  switch (scene) {
    case SceneType.explore:
      return const _SceneSpec(colors: [Color(0xFF1D4D8F), Color(0xFF30A1DC)], mainIcon: Icons.travel_explore, accentIcon: Icons.explore, tag: 'Discover');
    case SceneType.community:
      return const _SceneSpec(colors: [Color(0xFF5A2D8F), Color(0xFFAF5CC3)], mainIcon: Icons.groups_2, accentIcon: Icons.people_alt, tag: 'Community');
    case SceneType.booking:
      return const _SceneSpec(colors: [Color(0xFF0D7B71), Color(0xFF36B58B)], mainIcon: Icons.event_available, accentIcon: Icons.bolt, tag: 'Quick Booking');
    case SceneType.hiking:
      return const _SceneSpec(colors: [Color(0xFF2F5F3A), Color(0xFF6DAA55)], mainIcon: Icons.terrain, accentIcon: Icons.hiking, tag: 'Hiking');
    case SceneType.photography:
      return const _SceneSpec(colors: [Color(0xFF4A2A73), Color(0xFFD77E5D)], mainIcon: Icons.camera_alt, accentIcon: Icons.photo_camera_back, tag: 'Photography');
    case SceneType.food:
      return const _SceneSpec(colors: [Color(0xFF7F2E25), Color(0xFFE58A3B)], mainIcon: Icons.local_dining, accentIcon: Icons.restaurant_menu, tag: 'Food Tour');
    case SceneType.map:
      return const _SceneSpec(colors: [Color(0xFF184D83), Color(0xFF43A7D8)], mainIcon: Icons.map, accentIcon: Icons.place, tag: 'Nearby');
    case SceneType.completed:
      return const _SceneSpec(colors: [Color(0xFF31507E), Color(0xFF6F8AC3)], mainIcon: Icons.verified, accentIcon: Icons.check_circle, tag: 'Complete');
    case SceneType.cooking:
      return const _SceneSpec(colors: [Color(0xFF86542A), Color(0xFFE0A15A)], mainIcon: Icons.soup_kitchen, accentIcon: Icons.outdoor_grill, tag: 'Cooking');
  }
}

class Field extends StatelessWidget {
  const Field({
    super.key,
    required this.label,
    required this.hint,
    this.prefix,
    this.suffix,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.errorText,
  });
  final String label;
  final String hint;
  final String? prefix;
  final Widget? suffix;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixText: prefix,
            suffixIcon: suffix,
            hintText: hint,
            errorText: errorText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ]),
    );
  }
}

class ExperienceCard extends StatelessWidget {
  const ExperienceCard({super.key, required this.scene, required this.title, required this.host, required this.location, required this.desc, required this.onBook});
  final SceneType scene;
  final String title;
  final String host;
  final String location;
  final String desc;
  final VoidCallback onBook;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SceneImage(
            height: 165,
            borderRadius: BorderRadius.circular(10),
            title: title,
            subtitle: location,
            scene: scene,
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          Text('$host  |  $location', style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(desc),
          Align(alignment: Alignment.centerRight, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: kPurple), onPressed: onBook, child: const Text('Book'))),
        ]),
      ),
    );
  }
}

class NearbyItem extends StatelessWidget {
  const NearbyItem({super.key, required this.title, required this.subtitle, required this.action});
  final String title;
  final String subtitle;
  final String action;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: kLight, child: Icon(Icons.event_note, color: kPurple)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: FilledButton(style: FilledButton.styleFrom(backgroundColor: kPurple, minimumSize: const Size(70, 34)), onPressed: () {}, child: Text(action)),
      ),
    );
  }
}

class DashStat extends StatelessWidget {
  const DashStat({super.key, required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: const Color(0x22FFFFFF), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))]),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8), child]),
      ),
    );
  }
}

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: kPurple, size: 20),
      onPressed: () {
        if (onPressed != null) {
          onPressed!.call();
          return;
        }
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/app');
        }
      },
    );
  }
}

class _SmoothScrollBehavior extends ScrollBehavior {
  const _SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

class _TechPageTransitionsBuilder extends PageTransitionsBuilder {
  const _TechPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == '/') return child;

    final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    final scale = Tween<double>(begin: 0.98, end: 1.0).animate(curve);
    final slide = Tween<Offset>(begin: const Offset(0.08, 0.02), end: Offset.zero).animate(curve);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: ScaleTransition(scale: scale, child: child),
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF6F0FF), Color(0xFFE8F2FF), Color(0xFFFFFFFF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -80,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Color(0x33914BCF), Color(0x00FFFFFF)]),
              ),
            ),
          ),
          Positioned(
            right: -60,
            bottom: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Color(0x332F80FF), Color(0x00FFFFFF)]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
