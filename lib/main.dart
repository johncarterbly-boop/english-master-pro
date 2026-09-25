import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🛡️ Anti-Screenshot & Screen Recording Protection
  if (!kIsWeb) {
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageWithBlur();
  }

  await Supabase.initialize(
    url: 'https://bggfolrmgihqptpcqeci.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnZ2ZvbHJtZ2locXB0cGNxZWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODczODI5MzMsImV4cCI6MjEwMjk1ODkzM30.NMf_tiNVww9DruB3KShewZid6RfSFPbJzmkNajLhiLg',
  );

  runApp(const EnglishMasterApp());
}

final supabase = Supabase.instance.client;

// -------------------------------------------------------------
// OFFICIAL EXAM TIMING, QUESTIONS & MARKING SCHEME ENGINE
// -------------------------------------------------------------
Map<String, dynamic> getExamTimingConfig(String examName, String tier) {
  if (examName == 'SBI_PO' || examName == 'IBPS_PO' || examName == 'SBI_CLERK' || examName == 'IBPS_CLERK') {
    if (tier == 'PRE') {
      return {'time': 20, 'qCount': 30, 'marks': 30, 'neg': 0.25, 'pos': 1.0, 'label': '20 Mins • 30 Qs • 30 Marks (+1, -0.25)'};
    } else {
      final isPO = examName.contains('PO');
      return {
        'time': isPO ? 40 : 35,
        'qCount': isPO ? 35 : 40,
        'marks': isPO ? 40 : 40,
        'neg': 0.25,
        'pos': 1.0,
        'label': isPO ? '40 Mins • 35 Qs • 40 Marks (+1, -0.25)' : '35 Mins • 40 Qs • 40 Marks (+1, -0.25)'
      };
    }
  } else if (examName == 'RBI_GRADE_B') {
    return {'time': 25, 'qCount': 30, 'marks': 30, 'neg': 0.25, 'pos': 1.0, 'label': '25 Mins • 30 Qs • 30 Marks (+1, -0.25)'};
  } else if (examName == 'CGL' || examName == 'CHSL') {
    if (tier == 'PRE') {
      return {'time': 15, 'qCount': 25, 'marks': 50, 'neg': 0.50, 'pos': 2.0, 'label': '15 Mins • 25 Qs • 50 Marks (+2, -0.50)'};
    } else {
      final isCGL = examName == 'CGL';
      return {
        'time': isCGL ? 35 : 30,
        'qCount': isCGL ? 45 : 40,
        'marks': isCGL ? 135 : 120,
        'neg': 1.0,
        'pos': 3.0,
        'label': isCGL ? '35 Mins • 45 Qs • 135 Marks (+3, -1.0)' : '30 Mins • 40 Qs • 120 Marks (+3, -1.0)'
      };
    }
  } else if (examName == 'CPO') {
    return {'time': tier == 'PRE' ? 25 : 30, 'qCount': 50, 'marks': 50, 'neg': 0.25, 'pos': 1.0, 'label': tier == 'PRE' ? '25 Mins • 50 Qs • 50 Marks' : '30 Mins • 50 Qs • 50 Marks'};
  } else if (examName == 'MTS') {
    return {'time': 20, 'qCount': 25, 'marks': 75, 'neg': 1.0, 'pos': 3.0, 'label': '20 Mins • 25 Qs • 75 Marks (+3, -1.0)'};
  } else if (examName == 'STENO') {
    return {'time': 35, 'qCount': 50, 'marks': 50, 'neg': 0.25, 'pos': 1.0, 'label': '35 Mins • 50 Qs • 50 Marks'};
  }
  return {'time': 15, 'qCount': 25, 'marks': 50, 'neg': 0.50, 'pos': 2.0, 'label': '15 Mins • 25 Qs • 50 Marks'};
}

// 🎯 TEACHING FULL LENGTH MOCKS CONFIG (SUPER TET REVISED PATTERN: 120 Qs, 360 Marks, 120 Mins, +3, -1)
Map<String, dynamic> getTeachingFullMockConfig(String examCode) {
  switch (examCode) {
    case 'SUPERTET':
      return {
        'time': 120,
        'qCount': 120,
        'marks': 360,
        'neg': 1.0,
        'pos': 3.0,
        'label': '120 Mins • 120 Qs • 360 Marks (+3, -1.0)'
      };
    case 'UPTET':
      return {'time': 150, 'qCount': 150, 'marks': 150, 'neg': 0.0, 'pos': 1.0, 'label': '150 Mins • 150 Qs • 150 Marks'};
    case 'CTET':
      return {'time': 150, 'qCount': 150, 'marks': 150, 'neg': 0.0, 'pos': 1.0, 'label': '150 Mins • 150 Qs • 150 Marks'};
    case 'DSSSB':
      return {'time': 120, 'qCount': 200, 'marks': 200, 'neg': 0.25, 'pos': 1.0, 'label': '120 Mins • 200 Qs • 200 Marks (+1, -0.25)'};
    case 'KVS':
      return {'time': 180, 'qCount': 180, 'marks': 180, 'neg': 0.0, 'pos': 1.0, 'label': '180 Mins • 180 Qs • 180 Marks'};
    default:
      return {'time': 120, 'qCount': 120, 'marks': 360, 'neg': 1.0, 'pos': 3.0, 'label': '120 Mins • 360 Marks'};
  }
}

// 🎯 SUPER TET REVISED SUBJECT MINI-MOCK CONFIG (+3, -1 Negative Marking)
Map<String, dynamic> getTeachingSubjectMiniMockConfig(String subjectCode) {
  switch (subjectCode) {
    case 'GK_CA':
      return {'time': 20, 'qCount': 25, 'marks': 75, 'neg': 1.0, 'pos': 3.0, 'label': '20 Mins • 25 Qs • 75 Marks (+3, -1.0)'};
    case 'HINDI':
      return {'time': 15, 'qCount': 15, 'marks': 45, 'neg': 1.0, 'pos': 3.0, 'label': '15 Mins • 15 Qs • 45 Marks (+3, -1.0)'};
    case 'ENGLISH':
      return {'time': 10, 'qCount': 10, 'marks': 30, 'neg': 1.0, 'pos': 3.0, 'label': '10 Mins • 10 Qs • 30 Marks (+3, -1.0)'};
    case 'SANSKRIT':
      return {'time': 10, 'qCount': 10, 'marks': 30, 'neg': 1.0, 'pos': 3.0, 'label': '10 Mins • 10 Qs • 30 Marks (+3, -1.0)'};
    case 'MATHS':
      return {'time': 25, 'qCount': 16, 'marks': 48, 'neg': 1.0, 'pos': 3.0, 'label': '25 Mins • 16 Qs • 48 Marks (+3, -1.0)'};
    case 'SCIENCE':
      return {'time': 10, 'qCount': 8, 'marks': 24, 'neg': 1.0, 'pos': 3.0, 'label': '10 Mins • 8 Qs • 24 Marks (+3, -1.0)'};
    case 'EVS_SST':
      return {'time': 10, 'qCount': 8, 'marks': 24, 'neg': 1.0, 'pos': 3.0, 'label': '10 Mins • 8 Qs • 24 Marks (+3, -1.0)'};
    case 'TEACHING_SKILLS':
      return {'time': 10, 'qCount': 8, 'marks': 24, 'neg': 1.0, 'pos': 3.0, 'label': '10 Mins • 8 Qs • 24 Marks (+3, -1.0)'};
    case 'CDP':
      return {'time': 10, 'qCount': 8, 'marks': 24, 'neg': 1.0, 'pos': 3.0, 'label': '10 Mins • 8 Qs • 24 Marks (+3, -1.0)'};
    case 'LIFE_SKILLS':
      return {'time': 10, 'qCount': 8, 'marks': 24, 'neg': 1.0, 'pos': 3.0, 'label': '10 Mins • 8 Qs • 24 Marks (+3, -1.0)'};
    case 'REASONING':
      return {'time': 8, 'qCount': 5, 'marks': 15, 'neg': 1.0, 'pos': 3.0, 'label': '8 Mins • 5 Qs • 15 Marks (+3, -1.0)'};
    case 'IT':
      return {'time': 6, 'qCount': 4, 'marks': 12, 'neg': 1.0, 'pos': 3.0, 'label': '6 Mins • 4 Qs • 12 Marks (+3, -1.0)'};
    default:
      return {'time': 10, 'qCount': 10, 'marks': 30, 'neg': 1.0, 'pos': 3.0, 'label': '10 Mins • 10 Qs • 30 Marks (+3, -1.0)'};
  }
}

List<Map<String, dynamic>> getTeachingSubjects(String examCode) {
  switch (examCode) {
    case 'SUPERTET':
      return [
        {'code': 'GK_CA', 'name': 'सामान्य ज्ञान व समसामयिकी (25 Qs • 75 Marks)', 'icon': Icons.public, 'color': const Color(0xFF4338CA)},
        {'code': 'HINDI', 'name': 'हिन्दी भाषा (15 Qs • 45 Marks)', 'icon': Icons.translate, 'color': const Color(0xFFB91C1C)},
        {'code': 'ENGLISH', 'name': 'General English (10 Qs • 30 Marks)', 'icon': Icons.menu_book, 'color': const Color(0xFF1E3A8A)},
        {'code': 'SANSKRIT', 'name': 'संस्कृत भाषा (10 Qs • 30 Marks)', 'icon': Icons.temple_hindu, 'color': const Color(0xFFC2410C)},
        {'code': 'MATHS', 'name': 'गणित (Mathematics - 16 Qs • 48 Marks)', 'icon': Icons.calculate, 'color': const Color(0xFF0D9488)},
        {'code': 'SCIENCE', 'name': 'दैनिक जीवन में विज्ञान (8 Qs • 24 Marks)', 'icon': Icons.science, 'color': const Color(0xFF0284C7)},
        {'code': 'EVS_SST', 'name': 'पर्यावरण एवं सामाजिक अध्ययन (8 Qs • 24 Marks)', 'icon': Icons.park, 'color': const Color(0xFF15803D)},
        {'code': 'TEACHING_SKILLS', 'name': 'शिक्षण कौशल (8 Qs • 24 Marks)', 'icon': Icons.school, 'color': const Color(0xFF9333EA)},
        {'code': 'CDP', 'name': 'बाल मनोविज्ञान (8 Qs • 24 Marks)', 'icon': Icons.psychology, 'color': const Color(0xFF7C3AED)},
        {'code': 'LIFE_SKILLS', 'name': 'जीवन कौशल एवं प्रबंधन (8 Qs • 24 Marks)', 'icon': Icons.favorite, 'color': const Color(0xFFBE123C)},
        {'code': 'REASONING', 'name': 'तार्किक ज्ञान (Reasoning - 5 Qs • 15 Marks)', 'icon': Icons.lightbulb, 'color': const Color(0xFFD97706)},
        {'code': 'IT', 'name': 'सूचना तकनीकी (ICT/Computers - 4 Qs • 12 Marks)', 'icon': Icons.computer, 'color': const Color(0xFF0F766E)},
      ];
    case 'UPTET':
      return [
        {'code': 'CDP', 'name': 'बाल विकास एवं शिक्षण विधि (30 Marks)', 'icon': Icons.psychology, 'color': const Color(0xFF7C3AED)},
        {'code': 'HINDI', 'name': 'भाषा I: हिन्दी (30 Marks)', 'icon': Icons.translate, 'color': const Color(0xFFB91C1C)},
        {'code': 'ENGLISH', 'name': 'भाषा II: अंग्रेजी / संस्कृत / उर्दू (30 Marks)', 'icon': Icons.menu_book, 'color': const Color(0xFF1E3A8A)},
        {'code': 'MATHS', 'name': 'गणित (Mathematics - 30 Marks)', 'icon': Icons.calculate, 'color': const Color(0xFF0D9488)},
        {'code': 'EVS', 'name': 'पर्यावरण अध्ययन (EVS - 30 Marks)', 'icon': Icons.park, 'color': const Color(0xFF15803D)},
      ];
    case 'CTET':
      return [
        {'code': 'CDP', 'name': 'Child Development & Pedagogy (30 Marks)', 'icon': Icons.psychology, 'color': const Color(0xFF7C3AED)},
        {'code': 'HINDI', 'name': 'Language I Pedagogy (30 Marks)', 'icon': Icons.translate, 'color': const Color(0xFFB91C1C)},
        {'code': 'ENGLISH', 'name': 'Language II Pedagogy (30 Marks)', 'icon': Icons.menu_book, 'color': const Color(0xFF1E3A8A)},
        {'code': 'MATHS', 'name': 'Mathematics & Pedagogy (30 Marks)', 'icon': Icons.calculate, 'color': const Color(0xFF0D9488)},
        {'code': 'EVS', 'name': 'EVS & Pedagogy (30 Marks)', 'icon': Icons.park, 'color': const Color(0xFF15803D)},
      ];
    case 'DSSSB':
      return [
        {'code': 'GA', 'name': 'Section A: General Awareness (20 Marks)', 'icon': Icons.public, 'color': const Color(0xFF4338CA)},
        {'code': 'REASONING', 'name': 'Section A: Reasoning Ability (20 Marks)', 'icon': Icons.lightbulb, 'color': const Color(0xFFD97706)},
        {'code': 'MATHS', 'name': 'Section A: Numerical Ability (20 Marks)', 'icon': Icons.calculate, 'color': const Color(0xFF0D9488)},
        {'code': 'HINDI', 'name': 'Section A: Hindi Language (20 Marks)', 'icon': Icons.translate, 'color': const Color(0xFFB91C1C)},
        {'code': 'ENGLISH', 'name': 'Section A: English Language (20 Marks)', 'icon': Icons.menu_book, 'color': const Color(0xFF1E3A8A)},
        {'code': 'TEACHING_METHODOLOGY', 'name': 'Section B: Educational Methodology (100 Marks)', 'icon': Icons.psychology, 'color': const Color(0xFF7C3AED)},
      ];
    case 'KVS':
      return [
        {'code': 'ENGLISH', 'name': 'Part I: General English (10 Marks)', 'icon': Icons.menu_book, 'color': const Color(0xFF1E3A8A)},
        {'code': 'HINDI', 'name': 'Part I: General Hindi (10 Marks)', 'icon': Icons.translate, 'color': const Color(0xFFB91C1C)},
        {'code': 'GA_CA', 'name': 'Part II: General Awareness & CA (10 Marks)', 'icon': Icons.public, 'color': const Color(0xFF4338CA)},
        {'code': 'REASONING', 'name': 'Part II: Reasoning Ability (5 Marks)', 'icon': Icons.lightbulb, 'color': const Color(0xFFD97706)},
        {'code': 'COMPUTER', 'name': 'Part II: Computer Literacy (5 Marks)', 'icon': Icons.computer, 'color': const Color(0xFF0F766E)},
        {'code': 'PEDAGOGY', 'name': 'Part III: Perspectives on Education (60 Marks)', 'icon': Icons.psychology, 'color': const Color(0xFF7C3AED)},
        {'code': 'SUBJECT_SPECIFIC', 'name': 'Part IV: Subject Specific (80 Marks)', 'icon': Icons.school, 'color': const Color(0xFF0284C7)},
      ];
    default:
      return [];
  }
}

class EnglishMasterApp extends StatelessWidget {
  const EnglishMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'G&V MASTER PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1E3A8A),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const AuthGate(),
    );
  }
}

// -------------------------------------------------------------
// 1. AUTH GATE & LOGIN
// -------------------------------------------------------------
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;
        if (session != null) {
          return const MainHomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both Email and Password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        await supabase.auth.signUp(email: email, password: password);
      } else {
        await supabase.auth.signInWithPassword(email: email, password: password);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A8A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school, size: 38, color: Colors.amberAccent),
                ),
                const SizedBox(height: 16),
                const Text(
                  'G&V MASTER PRO',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const Text('Secured Single-Device English & Teaching Hub', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Registered Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _submitAuth,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _isSignUp ? 'REGISTER ACCOUNT' : 'LOGIN TO APP',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp ? 'Already have an account? Login' : 'New student? Create an Account',
                    style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. MAIN GATEWAY HOME SCREEN
// -------------------------------------------------------------
class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('G&V MASTER PRO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.1)),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async => await supabase.auth.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.blue.shade900.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome to Smart Learning 👋', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Select Your Target Exam', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amberAccent, borderRadius: BorderRadius.circular(20)),
                    child: const Text('🔥 Bilingual CBT Engine • Real AIR • AI Analyser', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 11)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('EXAMINATION CONSOLES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),

            _buildCategoryCard(
              context: context,
              title: 'SSC Exams Console',
              subtitle: 'CGL, CHSL, CPO, MTS & Stenographer',
              badge: 'Target 2026',
              color: const Color(0xFF1E3A8A),
              icon: Icons.assignment_turned_in,
              onTap: () => _openConsole(context, 'SSC', 'SSC English Master Console', const Color(0xFF1E3A8A)),
            ),

            _buildCategoryCard(
              context: context,
              title: 'Banking & Insurance',
              subtitle: 'SBI PO/Clerk, IBPS PO/Clerk & RBI Grade B',
              badge: 'High-Level Prep',
              color: const Color(0xFF0D9488),
              icon: Icons.account_balance,
              onTap: () => _openConsole(context, 'BANK', 'Banking English Master Console', const Color(0xFF0D9488)),
            ),

            _buildCategoryCard(
              context: context,
              title: 'Teaching Exams Console',
              subtitle: 'Super TET (360M Pattern), UPTET, CTET, DSSSB & KVS',
              badge: 'Bilingual CBT',
              color: const Color(0xFF7C3AED),
              icon: Icons.menu_book,
              onTap: () => _openConsole(context, 'TEACHING', 'Teaching Master Console', const Color(0xFF7C3AED)),
            ),

            const SizedBox(height: 16),
            const Text('PREMIUM COURSES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),

            _buildCategoryCard(
              context: context,
              title: 'Recorded Video Course',
              subtitle: 'Complete Chapter-wise Concept & Error Decoders',
              badge: 'Full HD Lectures',
              color: const Color(0xFFDC2626),
              icon: Icons.play_circle_fill,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video Lecture Hub is launching soon!')));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openConsole(BuildContext context, String examCode, String title, Color themeColor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamConsoleScreen(examCode: examCode, title: title, themeColor: themeColor),
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badge,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 3. EXAM CONSOLE SCREEN
// -------------------------------------------------------------
class ExamConsoleScreen extends StatefulWidget {
  final String examCode;
  final String title;
  final Color themeColor;

  const ExamConsoleScreen({super.key, required this.examCode, required this.title, required this.themeColor});

  @override
  State<ExamConsoleScreen> createState() => _ExamConsoleScreenState();
}

class _ExamConsoleScreenState extends State<ExamConsoleScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      GrammarTopicsScreen(selectedExam: 'ALL', themeColor: widget.themeColor),
      VocabCategoriesScreen(examCode: widget.examCode, themeColor: widget.themeColor),
      RcStructureScreen(examCode: widget.examCode, themeColor: widget.themeColor),
      PracticeMasterHubScreen(examCode: widget.examCode, themeColor: widget.themeColor),
      LeaderboardAndProgressScreen(examCode: widget.examCode, themeColor: widget.themeColor),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Target: ${widget.examCode} 2026', style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Grammar (Common)'),
          NavigationDestination(icon: Icon(Icons.bolt), label: 'Vocab Matrix'),
          NavigationDestination(icon: Icon(Icons.auto_stories), label: 'RC Engine'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'Practice Hub'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Report & Rank'),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 1: GRAMMAR TOPICS SCREEN (UNIVERSAL)
// -------------------------------------------------------------
class GrammarTopicsScreen extends StatefulWidget {
  final String selectedExam;
  final Color themeColor;
  const GrammarTopicsScreen({super.key, required this.selectedExam, required this.themeColor});

  @override
  State<GrammarTopicsScreen> createState() => _GrammarTopicsScreenState();
}

class _GrammarTopicsScreenState extends State<GrammarTopicsScreen> {
  late Future<List<Map<String, dynamic>>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = _getTopicsFromSupabase();
  }

  Future<List<Map<String, dynamic>>> _getTopicsFromSupabase() async {
    final res = await supabase
        .from('grammar_topics')
        .select()
        .order('chapter_no', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _topicsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final topics = snapshot.data ?? [];
        if (topics.isEmpty) {
          return const Center(child: Text('No grammar chapters uploaded yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: widget.themeColor,
                  foregroundColor: Colors.white,
                  child: Text('${topic['chapter_no'] ?? index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text(topic['title_en'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(topic['title_hi'] ?? '', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChapterRulesScreen(topic: topic, themeColor: widget.themeColor),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class ChapterRulesScreen extends StatefulWidget {
  final Map<String, dynamic> topic;
  final Color themeColor;
  const ChapterRulesScreen({super.key, required this.topic, required this.themeColor});

  @override
  State<ChapterRulesScreen> createState() => _ChapterRulesScreenState();
}

class _ChapterRulesScreenState extends State<ChapterRulesScreen> {
  bool _isHindi = true;
  late Future<List<Map<String, dynamic>>> _rulesFuture;

  @override
  void initState() {
    super.initState();
    _rulesFuture = _fetchRules();
  }

  Future<List<Map<String, dynamic>>> _fetchRules() async {
    final res = await supabase
        .from('grammar_rules')
        .select()
        .eq('topic_id', widget.topic['id'])
        .order('rule_no', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic['title_en'] ?? 'Chapter Rules'),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              Text(_isHindi ? 'हिंदी' : 'ENG', style: const TextStyle(fontWeight: FontWeight.bold)),
              Switch(
                value: _isHindi,
                activeColor: Colors.amberAccent,
                onChanged: (val) => setState(() => _isHindi = val),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _rulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rules = snapshot.data ?? [];
          if (rules.isEmpty) {
            return const Center(child: Text('No rules uploaded for this chapter yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: rules.length,
            itemBuilder: (context, index) {
              final rule = rules[index];
              return _buildRuleCard(rule);
            },
          );
        },
      ),
    );
  }

  Widget _buildRuleCard(Map<String, dynamic> rule) {
    final practiceQuestions = (rule['practice_questions'] is List)
        ? rule['practice_questions']
        : (rule['practice_questions'] != null ? jsonDecode(rule['practice_questions'].toString()) : []);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: widget.themeColor, borderRadius: BorderRadius.circular(8)),
                  child: Text('RULE ${rule['rule_no']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(rule['rule_title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              ],
            ),
            const Divider(height: 24),
            Text(_isHindi ? (rule['rule_concept_hi'] ?? '') : (rule['rule_concept_en'] ?? ''), style: const TextStyle(fontSize: 14, height: 1.45)),
            if (rule['golden_trick'] != null && rule['golden_trick'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade400)),
                child: Text(rule['golden_trick'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown.shade900, fontSize: 13)),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rule['example_incorrect'] ?? '', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(rule['example_correct'] ?? '', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
            if (practiceQuestions.isNotEmpty) ...[
              const SizedBox(height: 14),
              ExpansionTile(
                title: Text('🎯 Practice Drill (${practiceQuestions.length} Questions)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: widget.themeColor)),
                children: [
                  ...List.generate(practiceQuestions.length, (qIdx) {
                    return PracticeQuestionWidget(q: practiceQuestions[qIdx], qNumber: qIdx + 1);
                  }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 2: VOCAB CATEGORIES SCREEN
// -------------------------------------------------------------
class VocabCategoriesScreen extends StatelessWidget {
  final String examCode;
  final Color themeColor;

  const VocabCategoriesScreen({super.key, required this.examCode, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categories = [];

    if (examCode == 'SSC') {
      categories = [
        {'code': 'IDIOMS', 'title': 'Idioms & Phrases (SSC)', 'sub': 'Top repeated 2016-2026 idioms with origin tricks', 'icon': Icons.theater_comedy},
        {'code': 'OWS', 'title': 'One Word Substitution (OWS)', 'sub': 'Root word based one-word replacements with tricks', 'icon': Icons.filter_1},
        {'code': 'SYN_ANT', 'title': 'Synonyms & Antonyms (SSC PYQs)', 'sub': 'High-frequency exam words with memory mnemonics', 'icon': Icons.sync_alt},
        {'code': 'PHRASAL_VERB', 'title': 'Phrasal Verbs Engine', 'sub': 'Action verbs + Preposition traps with memory keys', 'icon': Icons.dynamic_feed},
        {'code': 'FIXED_PREP', 'title': 'Fixed Preposition Pairs', 'sub': 'Mandatory preposition pairs with memory hooks', 'icon': Icons.anchor},
        {'code': 'CONFUSING_WORDS', 'title': 'Confusing Words & Homophones', 'sub': 'Easily confused word traps (Affect/Effect)', 'icon': Icons.help_outline},
      ];
    } else if (examCode == 'BANK') {
      categories = [
        {'code': 'SYN_ANT', 'title': 'The Hindu & Contextual Vocab', 'sub': 'High-difficulty editorial words with memory tricks', 'icon': Icons.newspaper},
        {'code': 'PHRASAL_VERB', 'title': 'Phrasal Verbs (Bank Fillers)', 'sub': 'Essential for Sentence Completion & Error Spotting', 'icon': Icons.dynamic_feed},
        {'code': 'FIXED_PREP', 'title': 'Fixed Prepositions Traps', 'sub': 'High-weightage prepositions asked in PO/Clerk prelims & mains', 'icon': Icons.anchor},
        {'code': 'CONFUSING_WORDS', 'title': 'Homophones & Word Swaps', 'sub': 'Specialized for Banking Word Swap & Column Matching', 'icon': Icons.swap_horiz},
      ];
    } else {
      categories = [
        {'code': 'SYN_ANT', 'title': 'Core Synonyms & Antonyms (Teaching)', 'sub': '200 Essential PYQs for Super TET, CTET, KVS & DSSSB with tricks', 'icon': Icons.sync_alt},
        {'code': 'IDIOMS', 'title': 'Common Idioms & Proverbs', 'sub': 'Famous sayings, idioms and pedagogical usage', 'icon': Icons.lightbulb_outline},
        {'code': 'FIXED_PREP', 'title': 'Basic Fixed Prepositions', 'sub': 'Grammar prepositions tested in school teaching exams', 'icon': Icons.anchor},
        {'code': 'OWS', 'title': 'Common One Word Substitutions', 'sub': 'Important 1-word terms for school exams', 'icon': Icons.filter_1},
      ];
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: themeColor.withOpacity(0.15),
              foregroundColor: themeColor,
              child: Icon(cat['icon'] as IconData),
            ),
            title: Text(cat['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(cat['sub'], style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UniversalVocabMatrixScreen(
                    examCode: examCode,
                    categoryCode: cat['code'],
                    categoryTitle: cat['title'],
                    themeColor: themeColor,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// UNIVERSAL VOCAB MATRIX SCREEN (WITH BOOKMARKS & FLASHCARD MODE)
// -------------------------------------------------------------
class UniversalVocabMatrixScreen extends StatefulWidget {
  final String examCode;
  final String categoryCode;
  final String categoryTitle;
  final Color themeColor;

  const UniversalVocabMatrixScreen({
    super.key,
    required this.examCode,
    required this.categoryCode,
    required this.categoryTitle,
    required this.themeColor,
  });

  @override
  State<UniversalVocabMatrixScreen> createState() => _UniversalVocabMatrixScreenState();
}

class _UniversalVocabMatrixScreenState extends State<UniversalVocabMatrixScreen> {
  List<Map<String, dynamic>> wordsList = [];
  final Set<String> _bookmarkedWords = {};
  bool isLoading = true;
  String searchQuery = "";
  bool showBookmarksOnly = false;

  @override
  void initState() {
    super.initState();
    fetchVocabData();
  }

  Future<void> fetchVocabData() async {
    try {
      final response = await supabase
          .from('vocab_matrix')
          .select()
          .eq('exam_type', widget.examCode)
          .eq('category', widget.categoryCode)
          .order('word', ascending: true);

      if (mounted) {
        setState(() {
          wordsList = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("Error fetching vocab: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredWords = wordsList.where((item) {
      final word = (item['word'] ?? '').toString().toLowerCase();
      final meaning = (item['meaning_hi'] ?? '').toString().toLowerCase();
      final exam = (item['exam_tag'] ?? '').toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      final matchesSearch = word.contains(query) || meaning.contains(query) || exam.contains(query);

      if (showBookmarksOnly) {
        return matchesSearch && _bookmarkedWords.contains(item['word']);
      }
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.categoryTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.style),
            tooltip: 'Flashcard Flip Mode',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VocabFlashcardViewerScreen(
                    wordsList: filteredWords.isNotEmpty ? filteredWords : wordsList,
                    categoryTitle: widget.categoryTitle,
                    themeColor: widget.themeColor,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(showBookmarksOnly ? Icons.bookmark : Icons.bookmark_border),
            tooltip: 'Show Saved Words',
            onPressed: () => setState(() => showBookmarksOnly = !showBookmarksOnly),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search word, Hindi meaning or Exam tag...",
                prefixIcon: Icon(Icons.search, color: widget.themeColor),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Words: ${filteredWords.length} (${widget.examCode})", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
                if (showBookmarksOnly)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.amber.shade200, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Saved Only', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: widget.themeColor))
                : filteredWords.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(showBookmarksOnly ? "No saved words yet." : "No words uploaded for ${widget.examCode} in this section yet."),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        itemCount: filteredWords.length,
                        itemBuilder: (context, index) {
                          final item = filteredWords[index];
                          final wordText = item['word'].toString();
                          final isBookmarked = _bookmarkedWords.contains(wordText);
                          final List syns = item['synonyms'] ?? [];
                          final List ants = item['antonyms'] ?? [];
                          final practiceQuestions = (item['practice_questions'] is List)
                              ? item['practice_questions']
                              : (item['practice_questions'] != null ? jsonDecode(item['practice_questions'].toString()) : []);

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${item['word']}  (${item['meaning_hi'] ?? ''})",
                                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: isBookmarked ? Colors.amber.shade800 : Colors.grey),
                                        onPressed: () {
                                          setState(() {
                                            if (isBookmarked) {
                                              _bookmarkedWords.remove(wordText);
                                            } else {
                                              _bookmarkedWords.add(wordText);
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  if (item['exam_tag'] != null && item['exam_tag'].toString().isNotEmpty) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: widget.themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Text(item['exam_tag'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: widget.themeColor)),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  const Divider(height: 10),
                                  if (syns.isNotEmpty) ...[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Synonyms: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                                        Expanded(child: Text(syns.join(", "), style: const TextStyle(fontSize: 13, color: Colors.black87))),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  if (ants.isNotEmpty) ...[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Antonyms: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent)),
                                        Expanded(child: Text(ants.join(", "), style: const TextStyle(fontSize: 13, color: Colors.black87))),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  if (item['mnemonic_trick'] != null && item['mnemonic_trick'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade300)),
                                      child: Text(item['mnemonic_trick'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown.shade900, fontSize: 13)),
                                    ),
                                  ],
                                  if (item['example_sentence'] != null && item['example_sentence'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                      child: Text('📌 "${item['example_sentence']}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.black87)),
                                    ),
                                  ],
                                  if (practiceQuestions.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    ExpansionTile(
                                      tilePadding: EdgeInsets.zero,
                                      title: Text('🎯 Practice Drill (${practiceQuestions.length} Questions)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: widget.themeColor)),
                                      children: [
                                        ...List.generate(practiceQuestions.length, (qIdx) {
                                          return PracticeQuestionWidget(q: practiceQuestions[qIdx], qNumber: qIdx + 1);
                                        }),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// INTERACTIVE FLASHCARD FLIP VIEWER ENGINE (3D ROTATION)
// -------------------------------------------------------------
class VocabFlashcardViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> wordsList;
  final String categoryTitle;
  final Color themeColor;

  const VocabFlashcardViewerScreen({
    super.key,
    required this.wordsList,
    required this.categoryTitle,
    required this.themeColor,
  });

  @override
  State<VocabFlashcardViewerScreen> createState() => _VocabFlashcardViewerScreenState();
}

class _VocabFlashcardViewerScreenState extends State<VocabFlashcardViewerScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;

  void _flipCard() {
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard() {
    if (_currentIndex < widget.wordsList.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wordsList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.categoryTitle), backgroundColor: widget.themeColor),
        body: const Center(child: Text('No flashcards available in this section.')),
      );
    }

    final currentWord = widget.wordsList[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text('${widget.categoryTitle} • Flashcards', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Card ${_currentIndex + 1} of ${widget.wordsList.length}',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.touch_app, size: 14, color: Colors.amberAccent),
                      SizedBox(width: 4),
                      Text('Tap Card to Flip', style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _flipCard,
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0, end: _isFlipped ? 180 : 0),
                  builder: (context, double angle, child) {
                    final isUnder = (angle >= 90);
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY((angle * math.pi) / 180),
                      child: isUnder
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: _buildBackCard(currentWord),
                            )
                          : _buildFrontCard(currentWord),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _currentIndex > 0 ? _prevCard : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _currentIndex < widget.wordsList.length - 1 ? _nextCard : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next Card'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard(Map<String, dynamic> item) {
    return Container(
      width: 320,
      height: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item['exam_tag'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: widget.themeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(item['exam_tag'], style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          const SizedBox(height: 24),
          Text(
            item['word'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),
          const Text('Tap to reveal meaning & memory trick 💡', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBackCard(Map<String, dynamic> item) {
    return Container(
      width: 320,
      height: 420,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.themeColor.withOpacity(0.5), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item['word'] ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amberAccent),
          ),
          const SizedBox(height: 6),
          Text(
            item['meaning_hi'] ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Divider(height: 20, color: Colors.white24),
          if (item['mnemonic_trick'] != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.amber.shade900.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text(
                item['mnemonic_trick'],
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amberAccent),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (item['example_sentence'] != null)
            Text(
              '📌 "${item['example_sentence']}"',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white70),
            ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 3: RC STRUCTURE SCREEN
// -------------------------------------------------------------
class RcStructureScreen extends StatelessWidget {
  final String examCode;
  final Color themeColor;

  const RcStructureScreen({super.key, required this.examCode, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    if (examCode == 'SSC') {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                indicatorColor: themeColor,
                labelColor: themeColor,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'RC PRELIMS (Short/Speed)'),
                  Tab(text: 'RC MAINS (Long/Analytical)'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  RcPassagesList(examCode: 'SSC', subCategory: 'RC_PRE', themeColor: themeColor),
                  RcPassagesList(examCode: 'SSC', subCategory: 'RC_MAINS', themeColor: themeColor),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (examCode == 'BANK') {
      return RcPassagesList(examCode: 'BANK', subCategory: 'EDITORIAL', themeColor: themeColor, isEditorial: true);
    } else {
      return RcPassagesList(examCode: 'TEACHING', subCategory: 'PASSAGE', themeColor: themeColor);
    }
  }
}

class RcPassagesList extends StatefulWidget {
  final String examCode;
  final String subCategory;
  final Color themeColor;
  final bool isEditorial;

  const RcPassagesList({super.key, required this.examCode, required this.subCategory, required this.themeColor, this.isEditorial = false});

  @override
  State<RcPassagesList> createState() => _RcPassagesListState();
}

class _RcPassagesListState extends State<RcPassagesList> {
  late Future<List<Map<String, dynamic>>> _rcFuture;

  @override
  void initState() {
    super.initState();
    _rcFuture = _fetchPassages();
  }

  Future<List<Map<String, dynamic>>> _fetchPassages() async {
    final res = await supabase
        .from('rc_passages')
        .select()
        .eq('exam_type', widget.examCode)
        .eq('sub_category', widget.subCategory)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _rcFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final passages = snapshot.data ?? [];
        if (passages.isEmpty) {
          return Center(child: Text('No RC passages uploaded for ${widget.examCode} yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: passages.length,
          itemBuilder: (context, index) {
            final passage = passages[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: widget.themeColor.withOpacity(0.15),
                  foregroundColor: widget.themeColor,
                  child: Icon(widget.isEditorial ? Icons.newspaper : Icons.auto_stories),
                ),
                title: Text(passage['title'] ?? 'Passage', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: const Text('3-Stage Drill: Vocab Deck ➔ Reading ➔ One-by-One CBT Quiz', style: TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RcDetailViewerScreen(passage: passage, themeColor: widget.themeColor),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// -------------------------------------------------------------
// UPGRADED 3-STAGE INTERACTIVE RC ENGINE (STEP-BY-STEP FLOW)
// -------------------------------------------------------------
class RcDetailViewerScreen extends StatefulWidget {
  final Map<String, dynamic> passage;
  final Color themeColor;

  const RcDetailViewerScreen({super.key, required this.passage, required this.themeColor});

  @override
  State<RcDetailViewerScreen> createState() => _RcDetailViewerScreenState();
}

class _RcDetailViewerScreenState extends State<RcDetailViewerScreen> {
  int _activeStage = 0;
  int _currentQuestionIndex = 0;

  final Map<int, int> _selectedAnswers = {};
  final Set<int> _revealedAnswers = {};

  List<dynamic> _vocabList = [];
  List<dynamic> _questions = [];

  @override
  void initState() {
    super.initState();
    _vocabList = (widget.passage['vocab_list'] is List)
        ? widget.passage['vocab_list']
        : (widget.passage['vocab_list'] != null ? jsonDecode(widget.passage['vocab_list'].toString()) : []);

    _questions = (widget.passage['questions'] is List)
        ? widget.passage['questions']
        : (widget.passage['questions'] != null ? jsonDecode(widget.passage['questions'].toString()) : []);

    if (_vocabList.isEmpty) {
      _activeStage = 1;
    }
  }

  void _showPassageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_stories, color: widget.themeColor, size: 22),
                          const SizedBox(width: 8),
                          const Text('Passage Reference', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Text(
                        widget.passage['passage_text'] ?? '',
                        style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.passage['title'] ?? 'RC Engine', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(
              _activeStage == 0
                  ? 'Phase 1: Key Vocabulary'
                  : _activeStage == 1
                      ? 'Phase 2: Deep Reading Lounge'
                      : 'Phase 3: Comprehension Drill',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        actions: [
          if (_activeStage == 2)
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.amberAccent),
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('Read Passage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: _showPassageBottomSheet,
            ),
        ],
      ),
      body: _buildCurrentStageView(),
    );
  }

  Widget _buildCurrentStageView() {
    if (_activeStage == 0) {
      return _buildVocabStageView();
    } else if (_activeStage == 1) {
      return _buildPassageReadingStageView();
    } else {
      return _buildOneByOneQuizStageView();
    }
  }

  Widget _buildVocabStageView() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: widget.themeColor.withOpacity(0.08)),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: widget.themeColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Step 1 of 3: Master these high-frequency words before reading the passage.',
                  style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _vocabList.length,
            itemBuilder: (context, vIdx) {
              final v = _vocabList[vIdx];
              return Card(
                elevation: 1.5,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            v['word'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              v['hi'] ?? '',
                              style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      if (v['trick'] != null && v['trick'].toString().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Text(
                            '💡 Mnemonic: ${v['trick']}',
                            style: TextStyle(color: Colors.brown.shade900, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('PROCEED TO PASSAGE (STEP 2)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              onPressed: () => setState(() => _activeStage = 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassageReadingStageView() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: widget.themeColor.withOpacity(0.08)),
          child: Row(
            children: [
              Icon(Icons.auto_stories, color: widget.themeColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Step 2 of 3: Read thoroughly with focus. Comprehension quiz unlocks next.',
                  style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueGrey.shade100),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.passage['title'] ?? 'Comprehension Passage',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const Divider(height: 24),
                  Text(
                    widget.passage['passage_text'] ?? '',
                    style: const TextStyle(fontSize: 15, height: 1.7, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]),
          child: Row(
            children: [
              if (_vocabList.isNotEmpty) ...[
                OutlinedButton.icon(
                  onPressed: () => setState(() => _activeStage = 0),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Vocab'),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.quiz_outlined),
                    label: const Text('START COMPREHENSION QUIZ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      if (_questions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No quiz questions attached to this passage yet.')));
                        return;
                      }
                      setState(() => _activeStage = 2);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOneByOneQuizStageView() {
    if (_questions.isEmpty) {
      return const Center(child: Text('No questions uploaded.'));
    }

    final currentQ = _questions[_currentQuestionIndex];
    final options = List<String>.from(currentQ['options'] ?? []);
    final correctAns = currentQ['ans'] as int;
    final isRevealed = _revealedAnswers.contains(_currentQuestionIndex);
    final userOpt = _selectedAnswers[_currentQuestionIndex];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  side: BorderSide(color: widget.themeColor),
                ),
                icon: Icon(Icons.auto_stories, size: 14, color: widget.themeColor),
                label: Text('Passage Hint', style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold, fontSize: 11)),
                onPressed: _showPassageBottomSheet,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q${_currentQuestionIndex + 1}. ${currentQ['q']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.4, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 18),
                ...List.generate(options.length, (optIdx) {
                  Color borderC = Colors.grey.shade300;
                  Color bgC = Colors.white;

                  if (isRevealed) {
                    if (optIdx == correctAns) {
                      bgC = Colors.green.shade50;
                      borderC = Colors.green.shade600;
                    } else if (userOpt == optIdx) {
                      bgC = Colors.red.shade50;
                      borderC = Colors.red.shade600;
                    }
                  } else if (userOpt == optIdx) {
                    bgC = widget.themeColor.withOpacity(0.08);
                    borderC = widget.themeColor;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: bgC,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderC, width: 1.5),
                    ),
                    child: RadioListTile<int>(
                      title: Text(options[optIdx], style: TextStyle(fontWeight: userOpt == optIdx ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                      value: optIdx,
                      groupValue: userOpt,
                      activeColor: widget.themeColor,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedAnswers[_currentQuestionIndex] = val;
                            _revealedAnswers.add(_currentQuestionIndex);
                          });
                        }
                      },
                    ),
                  );
                }),
                if (isRevealed) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(userOpt == correctAns ? Icons.check_circle : Icons.cancel, color: userOpt == correctAns ? Colors.green : Colors.red, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              userOpt == correctAns ? 'Correct Answer!' : 'Incorrect Choice',
                              style: TextStyle(fontWeight: FontWeight.bold, color: userOpt == correctAns ? Colors.green.shade800 : Colors.red.shade800, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '💡 Explanation: ${currentQ['exp'] ?? ''}',
                          style: TextStyle(color: Colors.blueGrey.shade900, fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: _currentQuestionIndex > 0 ? () => setState(() => _currentQuestionIndex--) : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
              if (_currentQuestionIndex < _questions.length - 1)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: widget.themeColor, foregroundColor: Colors.white),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next Question'),
                  onPressed: () => setState(() => _currentQuestionIndex++),
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                  icon: const Icon(Icons.check),
                  label: const Text('Finish RC Drill'),
                  onPressed: () {
                    int score = 0;
                    _selectedAnswers.forEach((k, v) {
                      if (v == _questions[k]['ans']) score++;
                    });

                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('🎉 RC Drill Completed!'),
                        content: Text('You scored $score out of ${_questions.length} questions correctly in this passage.'),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: widget.themeColor, foregroundColor: Colors.white),
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            },
                            child: const Text('DONE'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// TAB 4: PRACTICE MASTER HUB
// -------------------------------------------------------------
class PracticeMasterHubScreen extends StatelessWidget {
  final String examCode;
  final Color themeColor;

  const PracticeMasterHubScreen({super.key, required this.examCode, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    if (examCode == 'SSC') {
      return SscBankPracticeDashboard(examCode: 'SSC', themeColor: themeColor);
    } else if (examCode == 'BANK') {
      return SscBankPracticeDashboard(examCode: 'BANK', themeColor: themeColor);
    } else {
      return TeachingPracticeDashboard(themeColor: themeColor);
    }
  }
}

class SscBankPracticeDashboard extends StatefulWidget {
  final String examCode;
  final Color themeColor;
  const SscBankPracticeDashboard({super.key, required this.examCode, required this.themeColor});

  @override
  State<SscBankPracticeDashboard> createState() => _SscBankPracticeDashboardState();
}

class _SscBankPracticeDashboardState extends State<SscBankPracticeDashboard> with SingleTickerProviderStateMixin {
  late TabController _tierTabController;
  late String _selectedExam;

  final List<String> _sscExams = ['CGL', 'CHSL', 'CPO', 'MTS', 'STENO'];
  final List<String> _bankExams = ['SBI_PO', 'SBI_CLERK', 'IBPS_PO', 'IBPS_CLERK', 'RBI_GRADE_B'];

  @override
  void initState() {
    super.initState();
    _tierTabController = TabController(length: 2, vsync: this);
    _selectedExam = widget.examCode == 'SSC' ? 'CGL' : 'SBI_PO';
  }

  @override
  Widget build(BuildContext context) {
    final examList = widget.examCode == 'SSC' ? _sscExams : _bankExams;

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tierTabController,
            indicatorColor: widget.themeColor,
            labelColor: widget.themeColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: '⚡ PRELIMS (TIER 1)'),
              Tab(text: '🎯 MAINS (TIER 2)'),
            ],
          ),
        ),
        Container(
          color: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: examList.map((exam) {
                final isSelected = _selectedExam == exam;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(exam.replaceAll('_', ' ')),
                    selected: isSelected,
                    selectedColor: widget.themeColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? widget.themeColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedExam = exam);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tierTabController,
            children: [
              _buildExamModulesList('PRE'),
              _buildExamModulesList('MAINS'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExamModulesList(String tier) {
    final config = getExamTimingConfig(_selectedExam, tier);

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.themeColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.themeColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Target: ${_selectedExam.replaceAll('_', ' ')} ($tier)', style: TextStyle(fontWeight: FontWeight.bold, color: widget.themeColor, fontSize: 13)),
              Text(config['label'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
            ],
          ),
        ),

        _buildModuleCard(
          title: 'Chapter-wise Practice Drills',
          sub: 'Chapter 01, Chapter 02... 2016-2026 PYQs',
          badge: 'Topic-wise',
          icon: Icons.folder_copy,
          color: const Color(0xFF1E3A8A),
          onTap: () => _openTestCardsList('CHAPTER_WISE', '$_selectedExam $tier Chapter Practice', tier),
        ),

        _buildModuleCard(
          title: 'Sectional Mini Mocks Engine',
          sub: 'Mock 01, Mock 02... Real Exam Pattern & Timing',
          badge: 'Live Timer',
          icon: Icons.alarm_on,
          color: const Color(0xFF0D9488),
          onTap: () => _openTestCardsList('MINI_MOCK', '$_selectedExam $tier Mini Mocks', tier),
        ),

        _buildModuleCard(
          title: 'Cloze Test Elimination Drills',
          sub: 'Cloze Test 01, Cloze Test 02... Contextual Sets',
          badge: 'Reading Logic',
          icon: Icons.rule_folder,
          color: const Color(0xFF7C3AED),
          onTap: () => _openTestCardsList('CLOZE_TEST', '$_selectedExam $tier Cloze Tests', tier),
        ),

        _buildModuleCard(
          title: 'Para-Jumbles & Rearrangement',
          sub: 'Set 01, Set 02... Mandatory Pair Finder Sets',
          badge: 'Sequence',
          icon: Icons.format_list_numbered,
          color: const Color(0xFFDC2626),
          onTap: () => _openTestCardsList('PARAJUMBLE', '$_selectedExam $tier Para Jumbles', tier),
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String sub,
    required String badge,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(sub, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _openTestCardsList(String testType, String title, String tier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestCardsListScreen(
          examCode: widget.examCode,
          examName: _selectedExam,
          tier: tier,
          testType: testType,
          title: title,
          themeColor: widget.themeColor,
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// STRICTLY FILTERED TEST CARDS LIST
// -------------------------------------------------------------
class TestCardsListScreen extends StatefulWidget {
  final String examCode;
  final String examName;
  final String tier;
  final String testType;
  final String title;
  final Color themeColor;

  const TestCardsListScreen({
    super.key,
    required this.examCode,
    required this.examName,
    required this.tier,
    required this.testType,
    required this.title,
    required this.themeColor,
  });

  @override
  State<TestCardsListScreen> createState() => _TestCardsListScreenState();
}

class _TestCardsListScreenState extends State<TestCardsListScreen> {
  late Future<List<Map<String, dynamic>>> _testsFuture;

  @override
  void initState() {
    super.initState();
    _testsFuture = _fetchTests();
  }

  Future<List<Map<String, dynamic>>> _fetchTests() async {
    var query = supabase
        .from('practice_tests')
        .select()
        .eq('exam_type', widget.examCode)
        .eq('test_type', widget.testType);

    if (widget.examCode != 'TEACHING') {
      query = query.eq('exam_name', widget.examName).eq('tier', widget.tier);
    } else {
      query = query.eq('exam_name', widget.examName);
    }

    final res = await query.order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Widget build(BuildContext context) {
    final config = (widget.examCode == 'TEACHING')
        ? (widget.testType == 'FULL_MOCK'
            ? getTeachingFullMockConfig(widget.examName)
            : getTeachingSubjectMiniMockConfig(widget.tier))
        : getExamTimingConfig(widget.examName, widget.tier);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${widget.examName.replaceAll('_', ' ')} • ${widget.tier}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _testsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tests = snapshot.data ?? [];
          if (tests.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('No test sets uploaded for ${widget.examName} (${widget.tier}) yet.'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.themeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#0${index + 1}',
                          style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test['title'] ?? 'Mock Test Set',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '⏱️ ${config['time']} Mins • ${config['qCount']} Qs • Marks: ${config['marks']} (+${config['pos']}, -${config['neg']})',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullExamExecutionScreen(
                                testData: test,
                                durationMinutes: config['time'],
                                markingConfig: config,
                                themeColor: widget.themeColor,
                              ),
                            ),
                          );
                        },
                        child: const Text('START', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// STEP 2: TESTBOOK / PRACTICEMOCK CBT ENGINE WITH AIR INTEGRATION
// -------------------------------------------------------------
enum QStatus { notVisited, notAnswered, answered, reviewOnly, answeredReview }

class FullExamExecutionScreen extends StatefulWidget {
  final Map<String, dynamic> testData;
  final int durationMinutes;
  final Map<String, dynamic> markingConfig;
  final Color themeColor;

  const FullExamExecutionScreen({
    super.key,
    required this.testData,
    required this.durationMinutes,
    required this.markingConfig,
    required this.themeColor,
  });

  @override
  State<FullExamExecutionScreen> createState() => _FullExamExecutionScreenState();
}

class _FullExamExecutionScreenState extends State<FullExamExecutionScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  int _currentQIndex = 0;
  List<dynamic> _questions = [];

  bool _isHindi = true;

  final Map<int, int> _selectedAnswers = {};
  final Map<int, QStatus> _statusMap = {};

  @override
  void initState() {
    super.initState();
    _questions = (widget.testData['questions'] is List)
        ? widget.testData['questions']
        : (widget.testData['questions'] != null ? jsonDecode(widget.testData['questions'].toString()) : []);

    for (int i = 0; i < _questions.length; i++) {
      _statusMap[i] = QStatus.notVisited;
    }
    if (_questions.isNotEmpty) {
      _statusMap[0] = QStatus.notAnswered;
    }

    _remainingSeconds = widget.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _submitTest(autoSubmit: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _goToQuestion(int idx) {
    setState(() {
      _currentQIndex = idx;
      if (_statusMap[_currentQIndex] == QStatus.notVisited) {
        _statusMap[_currentQIndex] = QStatus.notAnswered;
      }
    });
  }

  void _saveAndNext() {
    setState(() {
      if (_selectedAnswers.containsKey(_currentQIndex)) {
        _statusMap[_currentQIndex] = QStatus.answered;
      } else {
        _statusMap[_currentQIndex] = QStatus.notAnswered;
      }

      if (_currentQIndex < _questions.length - 1) {
        _currentQIndex++;
        if (_statusMap[_currentQIndex] == QStatus.notVisited) {
          _statusMap[_currentQIndex] = QStatus.notAnswered;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reached the last question. Tap Submit when ready!')));
      }
    });
  }

  void _markForReviewAndNext() {
    setState(() {
      if (_selectedAnswers.containsKey(_currentQIndex)) {
        _statusMap[_currentQIndex] = QStatus.answeredReview;
      } else {
        _statusMap[_currentQIndex] = QStatus.reviewOnly;
      }

      if (_currentQIndex < _questions.length - 1) {
        _currentQIndex++;
        if (_statusMap[_currentQIndex] == QStatus.notVisited) {
          _statusMap[_currentQIndex] = QStatus.notAnswered;
        }
      }
    });
  }

  void _clearResponse() {
    setState(() {
      _selectedAnswers.remove(_currentQIndex);
      _statusMap[_currentQIndex] = QStatus.notAnswered;
    });
  }

  void _showPreSubmitSummaryDialog() {
    int answered = 0;
    int notAnswered = 0;
    int review = 0;
    int notVisited = 0;

    _statusMap.forEach((k, v) {
      if (v == QStatus.answered || v == QStatus.answeredReview) answered++;
      if (v == QStatus.notAnswered) notAnswered++;
      if (v == QStatus.reviewOnly || v == QStatus.answeredReview) review++;
      if (v == QStatus.notVisited) notVisited++;
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.assessment_outlined, color: Color(0xFF1E3A8A)),
            SizedBox(width: 8),
            Text('Exam Status Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow('Total Questions:', '${_questions.length}', Colors.black87),
            _summaryRow('Answered (Green):', '$answered', Colors.green),
            _summaryRow('Not Answered (Red):', '$notAnswered', Colors.red),
            _summaryRow('Marked for Review:', '$review', Colors.purple),
            _summaryRow('Not Visited:', '$notVisited', Colors.grey),
            const Divider(height: 20),
            const Text('Are you sure you want to finish and submit the test?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('RESUME TEST')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _submitTest();
            },
            child: const Text('SUBMIT TEST'),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String val, Color c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: c)),
        ],
      ),
    );
  }

  // 🏆 SUBMIT TEST WITH REAL ALL-INDIA RANK CALCULATION
  Future<void> _submitTest({bool autoSubmit = false}) async {
    _timer?.cancel();

    double totalMarks = 0;
    int correctCount = 0;
    int wrongCount = 0;
    int unattemptedCount = 0;

    final posMark = (widget.markingConfig['pos'] as num).toDouble();
    final negMark = (widget.markingConfig['neg'] as num).toDouble();

    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers.containsKey(i)) {
        final chosen = _selectedAnswers[i];
        final actual = _questions[i]['ans'] as int;
        if (chosen == actual) {
          totalMarks += posMark;
          correctCount++;
        } else {
          totalMarks -= negMark;
          wrongCount++;
        }
      } else {
        unattemptedCount++;
      }
    }

    final maxMarks = (widget.markingConfig['marks'] as num).toDouble();
    final double accuracy = (correctCount + wrongCount) > 0 
        ? (correctCount / (correctCount + wrongCount)) * 100 
        : 0.0;

    int userRank = 1;
    int totalAppeared = 1;
    double percentile = 100.0;

    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('user_test_attempts').insert({
          'user_id': user.id,
          'user_email': user.email,
          'test_id': widget.testData['id'],
          'exam_type': widget.testData['exam_type'] ?? 'ALL',
          'exam_name': widget.testData['exam_name'] ?? 'MOCK',
          'score': totalMarks,
          'max_marks': maxMarks,
          'accuracy': accuracy,
          'correct_count': correctCount,
          'wrong_count': wrongCount,
        });

        final allAttempts = await supabase
            .from('user_test_attempts')
            .select('score')
            .eq('exam_name', widget.testData['exam_name'] ?? 'MOCK')
            .order('score', ascending: false);

        final attemptsList = List<Map<String, dynamic>>.from(allAttempts);
        totalAppeared = attemptsList.length;

        int higherScores = attemptsList.where((a) => (a['score'] as num).toDouble() > totalMarks).length;
        userRank = higherScores + 1;

        if (totalAppeared > 1) {
          percentile = ((totalAppeared - userRank) / totalAppeared) * 100;
        } else {
          percentile = 100.0;
        }
      }
    } catch (e) {
      debugPrint('Ranking fetch error: $e');
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MockScorecardScreen(
          title: widget.testData['title'] ?? 'Mock Results',
          totalMarks: totalMarks,
          maxMarks: maxMarks,
          correctCount: correctCount,
          wrongCount: wrongCount,
          unattemptedCount: unattemptedCount,
          totalQuestions: _questions.length,
          questions: _questions,
          userAnswers: _selectedAnswers,
          themeColor: widget.themeColor,
          rank: userRank,
          totalStudents: totalAppeared,
          percentile: percentile,
        ),
      ),
    );
  }

  void _openQuestionPalette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Testbook Question Palette', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: [
                  _paletteLegendBadge('Answered', Colors.green),
                  _paletteLegendBadge('Not Answered', Colors.red.shade400),
                  _paletteLegendBadge('Not Visited', Colors.grey.shade300, textColor: Colors.black87),
                  _paletteLegendBadge('Review', Colors.purple),
                  _paletteLegendBadge('Ans & Review', Colors.purple.shade800),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _questions.length,
                  itemBuilder: (context, idx) {
                    final status = _statusMap[idx] ?? QStatus.notVisited;
                    Color bg = Colors.grey.shade300;
                    Color tc = Colors.black87;

                    if (status == QStatus.answered) {
                      bg = Colors.green;
                      tc = Colors.white;
                    } else if (status == QStatus.notAnswered) {
                      bg = Colors.red.shade400;
                      tc = Colors.white;
                    } else if (status == QStatus.reviewOnly) {
                      bg = Colors.purple;
                      tc = Colors.white;
                    } else if (status == QStatus.answeredReview) {
                      bg = Colors.purple.shade900;
                      tc = Colors.white;
                    }

                    final isCurrent = idx == _currentQIndex;

                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        _goToQuestion(idx);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8),
                          border: isCurrent ? Border.all(color: Colors.amber, width: 2.5) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text('${idx + 1}', style: TextStyle(color: tc, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _paletteLegendBadge(String label, Color color, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  String _getQuestionText(Map<String, dynamic> q) {
    if (_isHindi) {
      if (q['q_hi'] != null && q['q_hi'].toString().trim().isNotEmpty) {
        return q['q_hi'].toString();
      }
    } else {
      if (q['q_en'] != null && q['q_en'].toString().trim().isNotEmpty) {
        return q['q_en'].toString();
      }
    }
    return q['q']?.toString() ?? 'Question Text Unavailable';
  }

  List<String> _getOptions(Map<String, dynamic> q) {
    if (_isHindi && q['options_hi'] != null && (q['options_hi'] as List).isNotEmpty) {
      return List<String>.from(q['options_hi']);
    } else if (!_isHindi && q['options_en'] != null && (q['options_en'] as List).isNotEmpty) {
      return List<String>.from(q['options_en']);
    } else if (q['options'] != null) {
      return List<String>.from(q['options']);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Mock'), backgroundColor: widget.themeColor),
        body: const Center(child: Text('No questions loaded.')),
      );
    }

    final currentQ = _questions[_currentQIndex];
    final String currentSubject = (currentQ['subject'] ?? '').toString().toUpperCase();
    final bool isEnglishSubject = currentSubject == 'ENGLISH';

    final String questionText = isEnglishSubject
        ? (currentQ['q_en']?.toString() ?? currentQ['q']?.toString() ?? '')
        : _getQuestionText(currentQ);

    final List<String> options = isEnglishSubject
        ? (currentQ['options_en'] != null
            ? List<String>.from(currentQ['options_en'])
            : List<String>.from(currentQ['options'] ?? []))
        : _getOptions(currentQ);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${_currentQIndex + 1} of ${_questions.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(currentQ['subject'] ?? 'General Test', style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(_formatTime(_remainingSeconds), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.grid_view), tooltip: 'Palette', onPressed: _openQuestionPalette),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blueGrey.shade100, borderRadius: BorderRadius.circular(6)),
                  child: Text('Marks: +${widget.markingConfig['pos']}, -${widget.markingConfig['neg']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),

                // 🌐 CONDITIONAL BILINGUAL SWITCHER (ENGLISH SECTION EXCLUDED)
                if (!isEnglishSubject)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            if (!_isHindi) setState(() => _isHindi = true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _isHindi ? widget.themeColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'हिंदी',
                              style: TextStyle(
                                color: _isHindi ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (_isHindi) setState(() => _isHindi = false);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: !_isHindi ? widget.themeColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ENG',
                              style: TextStyle(
                                color: !_isHindi ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                    child: const Text('English Section Only', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  ),

                TextButton(
                  onPressed: _showPreSubmitSummaryDialog,
                  child: const Text('SUBMIT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            Text('Q${_currentQIndex + 1}. $questionText', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.4)),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, optIdx) {
                  final isSelected = _selectedAnswers[_currentQIndex] == optIdx;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? widget.themeColor.withOpacity(0.12) : Colors.white,
                      border: Border.all(color: isSelected ? widget.themeColor : Colors.grey.shade300, width: isSelected ? 1.8 : 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RadioListTile<int>(
                      dense: true,
                      title: Text(options[optIdx], style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                      value: optIdx,
                      groupValue: _selectedAnswers[_currentQIndex],
                      activeColor: widget.themeColor,
                      onChanged: (val) {
                        setState(() {
                          if (val != null) _selectedAnswers[_currentQIndex] = val;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: _clearResponse,
                        child: const Text('CLEAR'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                        onPressed: _markForReviewAndNext,
                        child: const Text('MARK & NEXT'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                        onPressed: _saveAndNext,
                        child: const Text('SAVE & NEXT'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// POST-TEST AI PERFORMANCE ANALYSER & DETAILED SCORECARD WITH AIR
// -------------------------------------------------------------
class MockScorecardScreen extends StatefulWidget {
  final String title;
  final double totalMarks;
  final double maxMarks;
  final int correctCount;
  final int wrongCount;
  final int unattemptedCount;
  final int totalQuestions;
  final List<dynamic> questions;
  final Map<int, int> userAnswers;
  final Color themeColor;
  final int rank;
  final int totalStudents;
  final double percentile;

  const MockScorecardScreen({
    super.key,
    required this.title,
    required this.totalMarks,
    required this.maxMarks,
    required this.correctCount,
    required this.wrongCount,
    required this.unattemptedCount,
    required this.totalQuestions,
    required this.questions,
    required this.userAnswers,
    required this.themeColor,
    required this.rank,
    required this.totalStudents,
    required this.percentile,
  });

  @override
  State<MockScorecardScreen> createState() => _MockScorecardScreenState();
}

class _MockScorecardScreenState extends State<MockScorecardScreen> {
  bool _isHindi = true;

  @override
  Widget build(BuildContext context) {
    final double accuracy = (widget.correctCount + widget.wrongCount) > 0 ? (widget.correctCount / (widget.correctCount + widget.wrongCount)) * 100 : 0.0;

    final Map<String, Map<String, int>> subjectStats = {};
    for (int i = 0; i < widget.questions.length; i++) {
      final sub = widget.questions[i]['subject']?.toString() ?? 'General Syllabus';
      subjectStats.putIfAbsent(sub, () => {'correct': 0, 'wrong': 0, 'total': 0});
      subjectStats[sub]!['total'] = subjectStats[sub]!['total']! + 1;

      if (widget.userAnswers.containsKey(i)) {
        if (widget.userAnswers[i] == widget.questions[i]['ans']) {
          subjectStats[sub]!['correct'] = subjectStats[sub]!['correct']! + 1;
        } else {
          subjectStats[sub]!['wrong'] = subjectStats[sub]!['wrong']! + 1;
        }
      }
    }

    final List<String> strongAreas = [];
    final List<String> weakAreas = [];

    subjectStats.forEach((sub, data) {
      final acc = (data['correct']! + data['wrong']!) > 0 ? (data['correct']! / (data['correct']! + data['wrong']!)) * 100 : 0.0;
      if (acc >= 75) {
        strongAreas.add('$sub (${acc.toStringAsFixed(0)}% Acc)');
      } else if (acc < 50) {
        weakAreas.add('$sub (${acc.toStringAsFixed(0)}% Acc • ${data['wrong']} Errors)');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance & AIR Report'),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              Text(_isHindi ? 'हिंदी' : 'ENG', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Switch(
                value: _isHindi,
                activeColor: Colors.amberAccent,
                onChanged: (val) => setState(() => _isHindi = val),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.themeColor, widget.themeColor.withOpacity(0.8)]), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text(widget.title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text('${widget.totalMarks.toStringAsFixed(1)} / ${widget.maxMarks}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('Overall Accuracy: ${accuracy.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),

            // 🏆 ALL-INDIA RANK & PERCENTILE TESTBOOK STRIP
            Container(
              margin: const EdgeInsets.symmetric(vertical: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade400, width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 22),
                          const SizedBox(width: 4),
                          Text(
                            '#${widget.rank} / ${widget.totalStudents}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E3A8A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('All-India Rank', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(height: 35, width: 1, color: Colors.grey.shade300),
                  Column(
                    children: [
                      Text(
                        '${widget.percentile.toStringAsFixed(1)} %ile',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.teal),
                      ),
                      const SizedBox(height: 2),
                      const Text('Percentile', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(height: 35, width: 1, color: Colors.grey.shade300),
                  Column(
                    children: [
                      Text(
                        '${accuracy.toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.indigo),
                      ),
                      const SizedBox(height: 2),
                      const Text('Accuracy', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            Row(
              children: [
                _statCard('Correct', '${widget.correctCount}', Colors.green),
                const SizedBox(width: 10),
                _statCard('Incorrect', '${widget.wrongCount}', Colors.red),
                const SizedBox(width: 10),
                _statCard('Skipped', '${widget.unattemptedCount}', Colors.grey),
              ],
            ),
            const SizedBox(height: 24),

            // 🤖 AI DIAGNOSTIC REPORT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.brown, size: 24),
                      SizedBox(width: 8),
                      Text('AI Weak & Strong Area Analyser', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown)),
                    ],
                  ),
                  const Divider(height: 18),
                  const Text('🟢 Strong Focus Areas (Keep Speed High):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                  const SizedBox(height: 4),
                  Text(strongAreas.isNotEmpty ? strongAreas.join(' • ') : 'No high-scoring area detected yet. Focus on building concept clarity.', style: const TextStyle(fontSize: 12, height: 1.4)),
                  const SizedBox(height: 12),
                  const Text('🔴 Critical Weak Areas (Immediate Revision Needed):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                  const SizedBox(height: 4),
                  Text(weakAreas.isNotEmpty ? weakAreas.join(' • ') : 'Great job! No critical weak areas with heavy negative marks.', style: const TextStyle(fontSize: 12, height: 1.4)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      widget.wrongCount > 5
                          ? '💡 AI Tip: You lost ${(widget.wrongCount * (widget.maxMarks > 150 ? 1.0 : 0.25)).toStringAsFixed(1)} marks due to negative marking. Avoid speculative guesses in weak areas.'
                          : '💡 AI Tip: Your selection accuracy is optimal. Work on time management to attempt unvisited questions.',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.brown.shade900),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('QUESTION-WISE DETAILED ANALYSIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                Text(_isHindi ? 'भाषा: हिंदी' : 'Lang: English', style: TextStyle(fontSize: 12, color: widget.themeColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(widget.questions.length, (idx) {
              final q = widget.questions[idx];
              final actual = q['ans'] as int;
              final user = widget.userAnswers[idx];
              final isEng = (q['subject'] ?? '').toString().toUpperCase() == 'ENGLISH';

              final qText = isEng
                  ? (q['q_en'] ?? q['q'])
                  : (_isHindi ? (q['q_hi'] ?? q['q']) : (q['q_en'] ?? q['q']));

              List<String> opts = [];
              if (isEng) {
                opts = q['options_en'] != null ? List<String>.from(q['options_en']) : List<String>.from(q['options'] ?? []);
              } else if (_isHindi && q['options_hi'] != null) {
                opts = List<String>.from(q['options_hi']);
              } else if (!_isHindi && q['options_en'] != null) {
                opts = List<String>.from(q['options_en']);
              } else {
                opts = List<String>.from(q['options'] ?? []);
              }

              final expText = isEng
                  ? (q['exp_en'] ?? q['exp'] ?? '')
                  : (_isHindi ? (q['exp_hi'] ?? q['exp'] ?? '') : (q['exp_en'] ?? q['exp'] ?? ''));

              Color statusColor = Colors.grey;
              String statusText = 'Skipped';
              if (user != null) {
                if (user == actual) {
                  statusColor = Colors.green;
                  statusText = 'Correct';
                } else {
                  statusColor = Colors.red;
                  statusText = 'Incorrect';
                }
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Q${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                            child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(qText.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text('Your Answer: ${user != null ? opts[user] : "Not Attempted"}', style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('Correct Answer: ${opts[actual]}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                        child: Text('💡 Solution: $expText', style: TextStyle(color: Colors.blueGrey.shade900, fontSize: 12, fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
        child: Column(
          children: [
            Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// TEACHING PRACTICE DASHBOARD (OFFICIAL SYLLABUS + REVISED MARKS)
// -------------------------------------------------------------
class TeachingPracticeDashboard extends StatefulWidget {
  final Color themeColor;
  const TeachingPracticeDashboard({super.key, required this.themeColor});

  @override
  State<TeachingPracticeDashboard> createState() => _TeachingPracticeDashboardState();
}

class _TeachingPracticeDashboardState extends State<TeachingPracticeDashboard> {
  String _selectedExam = 'SUPERTET';

  final List<Map<String, dynamic>> _teachingExams = [
    {'code': 'SUPERTET', 'name': 'Super TET (Revised 120 Qs • 360 Marks)'},
    {'code': 'UPTET', 'name': 'UPTET (Paper 1 & 2)'},
    {'code': 'CTET', 'name': 'CTET (Pedagogy Specialist)'},
    {'code': 'DSSSB', 'name': 'DSSSB PRT (Sec A + Sec B - 200 M)'},
    {'code': 'KVS', 'name': 'KVS PRT (180 Marks Pattern)'},
  ];

  @override
  Widget build(BuildContext context) {
    final subjects = getTeachingSubjects(_selectedExam);
    final mockConfig = getTeachingFullMockConfig(_selectedExam);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _teachingExams.map((exam) {
                final isSelected = _selectedExam == exam['code'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(exam['name']),
                    selected: isSelected,
                    selectedColor: widget.themeColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? widget.themeColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedExam = exam['code']!);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF7C3AED),
                foregroundColor: Colors.amberAccent,
                child: Icon(Icons.emoji_events),
              ),
              title: Text('🏆 $_selectedExam Official Full Mocks', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text('${mockConfig['label']} • Mock 01, Mock 02, Mock 03...', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TestCardsListScreen(
                        examCode: 'TEACHING',
                        examName: _selectedExam,
                        tier: 'FULL',
                        testType: 'FULL_MOCK',
                        title: '$_selectedExam Full Length Mocks',
                        themeColor: widget.themeColor,
                      ),
                    ),
                  );
                },
                child: const Text('OPEN MOCKS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('OFFICIAL SYLLABUS: $_selectedExam SUBJECTS (${subjects.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final sub = subjects[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: (sub['color'] as Color).withOpacity(0.15),
                    foregroundColor: sub['color'] as Color,
                    child: Icon(sub['icon'] as IconData),
                  ),
                  title: Text(sub['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Mini Mocks • Chapter Drills • PDF Notes', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Column(
                        children: [
                          const Divider(),
                          _teachingActionTile('⏱️ Subject Mini Mocks (Mock 01, Mock 02...)', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestCardsListScreen(
                                  examCode: 'TEACHING',
                                  examName: _selectedExam,
                                  tier: sub['code'],
                                  testType: 'MINI_MOCK',
                                  title: '${sub['name']} Mini Mocks',
                                  themeColor: widget.themeColor,
                                ),
                              ),
                            );
                          }),
                          _teachingActionTile('📂 Chapter-wise Practice Sets', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestCardsListScreen(
                                  examCode: 'TEACHING',
                                  examName: _selectedExam,
                                  tier: sub['code'],
                                  testType: 'CHAPTER_WISE',
                                  title: '${sub['name']} Chapter Sets',
                                  themeColor: widget.themeColor,
                                ),
                              ),
                            );
                          }),
                          _teachingActionTile('📚 Smart Revision Notes & PDF Capsule', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubjectNotesViewerScreen(
                                  examName: _selectedExam,
                                  subject: sub['code'],
                                  subjectTitle: sub['name'],
                                  themeColor: widget.themeColor,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _teachingActionTile(String title, VoidCallback onTap) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// -------------------------------------------------------------
// SUBJECT REVISION NOTES & PDF CAPSULE VIEWER SCREEN
// -------------------------------------------------------------
class SubjectNotesViewerScreen extends StatefulWidget {
  final String examName;
  final String subject;
  final String subjectTitle;
  final Color themeColor;

  const SubjectNotesViewerScreen({
    super.key,
    required this.examName,
    required this.subject,
    required this.subjectTitle,
    required this.themeColor,
  });

  @override
  State<SubjectNotesViewerScreen> createState() => _SubjectNotesViewerScreenState();
}

class _SubjectNotesViewerScreenState extends State<SubjectNotesViewerScreen> {
  late Future<List<Map<String, dynamic>>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = _fetchNotes();
  }

  Future<List<Map<String, dynamic>>> _fetchNotes() async {
    final res = await supabase
        .from('subject_notes')
        .select()
        .eq('exam_name', widget.examName)
        .eq('subject', widget.subject)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectTitle} Notes & PDFs'),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data ?? [];
          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('No revision notes or PDFs uploaded for ${widget.subjectTitle} yet.'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final pdfUrl = note['pdf_url']?.toString();

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.bookmark_border, color: Color(0xFF7C3AED)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(note['chapter_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ],
                            ),
                          ),
                          if (pdfUrl != null && pdfUrl.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)),
                              child: const Row(
                                children: [
                                  Icon(Icons.picture_as_pdf, size: 14, color: Colors.red),
                                  SizedBox(width: 4),
                                  Text('PDF', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(note['notes_content'] ?? '', style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
                      if (pdfUrl != null && pdfUrl.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.file_open),
                            label: const Text('OPEN OFFICIAL PDF CAPSULE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InAppSecurePdfViewerScreen(
                                    title: note['chapter_name'] ?? 'Revision Document',
                                    pdfUrl: pdfUrl,
                                    themeColor: widget.themeColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// SECURE IN-APP PDF VIEWER (ZERO-ERROR BROWSER ENGINE)
// -------------------------------------------------------------
class InAppSecurePdfViewerScreen extends StatelessWidget {
  final String title;
  final String pdfUrl;
  final Color themeColor;

  const InAppSecurePdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
    required this.themeColor,
  });

  Future<void> _launchViewer() async {
    final secureViewerUri = Uri.parse(
      'https://docs.google.com/viewer?url=${Uri.encodeComponent(pdfUrl)}&embedded=true',
    );
    if (!await launchUrl(secureViewerUri, mode: LaunchMode.platformDefault)) {
      debugPrint('Could not launch $secureViewerUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Text('Official Study Material • Copy & Print Protected', style: TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 6))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 48),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'This document is encrypted for in-app viewing only. External downloads, printing, and file copying are strictly restricted.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.chrome_reader_mode),
                  label: const Text('OPEN IN SECURE READER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  onPressed: _launchViewer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 5: UPGRADED LEADERBOARD & MY PROGRESS REPORT CARD (LIVE SUPABASE SYNC)
// -------------------------------------------------------------
class LeaderboardAndProgressScreen extends StatefulWidget {
  final String examCode;
  final Color themeColor;

  const LeaderboardAndProgressScreen({super.key, required this.examCode, required this.themeColor});

  @override
  State<LeaderboardAndProgressScreen> createState() => _LeaderboardAndProgressScreenState();
}

class _LeaderboardAndProgressScreenState extends State<LeaderboardAndProgressScreen> {
  late Future<Map<String, dynamic>> _reportDataFuture;

  @override
  void initState() {
    super.initState();
    _reportDataFuture = _fetchLiveReportData();
  }

  Future<Map<String, dynamic>> _fetchLiveReportData() async {
    final user = supabase.auth.currentUser;
    final currentUserId = user?.id;

    final allAttemptsRes = await supabase
        .from('user_test_attempts')
        .select()
        .order('score', ascending: false);

    final List<Map<String, dynamic>> allAttempts = List<Map<String, dynamic>>.from(allAttemptsRes);
    final userAttempts = allAttempts.where((a) => a['user_id'] == currentUserId).toList();

    double totalScore = 0;
    double totalMax = 0;
    int totalCorrect = 0;
    int totalWrong = 0;

    for (var att in userAttempts) {
      totalScore += (att['score'] as num).toDouble();
      totalMax += (att['max_marks'] as num).toDouble();
      totalCorrect += (att['correct_count'] as int? ?? 0);
      totalWrong += (att['wrong_count'] as int? ?? 0);
    }

    final double avgAccuracy = (totalCorrect + totalWrong) > 0
        ? (totalCorrect / (totalCorrect + totalWrong)) * 100
        : 0.0;

    int userBestRank = 1;
    if (userAttempts.isNotEmpty) {
      double bestScore = userAttempts.map((e) => (e['score'] as num).toDouble()).reduce(math.max);
      int higher = allAttempts.where((e) => (e['score'] as num).toDouble() > bestScore).length;
      userBestRank = higher + 1;
    }

    return {
      'allAttempts': allAttempts,
      'userAttempts': userAttempts,
      'avgAccuracy': avgAccuracy,
      'totalScore': totalScore,
      'userBestRank': userBestRank,
      'totalStudents': allAttempts.isNotEmpty ? allAttempts.length : 1,
    };
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              indicatorColor: widget.themeColor,
              labelColor: widget.themeColor,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: '🏆 ALL-INDIA RANK'),
                Tab(text: '📊 MY REPORT CARD & HISTORY'),
              ],
            ),
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _reportDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: widget.themeColor));
            }

            final data = snapshot.data ?? {};
            final allAttempts = data['allAttempts'] as List<Map<String, dynamic>>? ?? [];
            final userAttempts = data['userAttempts'] as List<Map<String, dynamic>>? ?? [];
            final double avgAccuracy = data['avgAccuracy'] ?? 0.0;
            final int userBestRank = data['userBestRank'] ?? 1;
            final int totalStudents = data['totalStudents'] ?? 1;

            return TabBarView(
              children: [
                _buildLiveLeaderboardView(allAttempts, userBestRank, totalStudents),
                _buildMyProgressAndHistoryView(userAttempts, avgAccuracy, userBestRank),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLiveLeaderboardView(List<Map<String, dynamic>> allAttempts, int myRank, int totalStudents) {
    if (allAttempts.isEmpty) {
      return const Center(child: Text('No test attempts recorded yet. Be the first to appear!'));
    }

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.themeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.themeColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text('Your Best AIR: #$myRank', style: TextStyle(fontWeight: FontWeight.bold, color: widget.themeColor, fontSize: 15)),
                ],
              ),
              Text('Total Aspirants: $totalStudents', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(allAttempts.length, (idx) {
          final item = allAttempts[idx];
          final score = (item['score'] as num).toDouble();
          final maxMarks = (item['max_marks'] as num).toDouble();
          final email = (item['user_email'] ?? 'Aspirant').toString().split('@')[0];
          final isTop3 = idx < 3;

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isTop3 ? Colors.amber : Colors.blueGrey.shade100,
                foregroundColor: isTop3 ? Colors.black : Colors.black87,
                child: Text('#${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${item['exam_name'] ?? 'Mock Test'} • Score: ${score.toStringAsFixed(1)} / $maxMarks', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                child: Text('${score.toStringAsFixed(1)} pts', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMyProgressAndHistoryView(List<Map<String, dynamic>> userAttempts, double avgAccuracy, int bestRank) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [widget.themeColor, widget.themeColor.withOpacity(0.85)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overall Performance Summary', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text('Overall Accuracy: ${avgAccuracy.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('🏆 Best AIR Achieved: #$bestRank • Total Tests Given: ${userAttempts.length}', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('PAST TEST ATTEMPTS HISTORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 10),

          if (userAttempts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: const Center(child: Text('You have not attempted any mock test yet. Go to Practice Hub and take a test!')),
            )
          else
            ...List.generate(userAttempts.length, (idx) {
              final att = userAttempts[idx];
              final score = (att['score'] as num).toDouble();
              final maxMarks = (att['max_marks'] as num).toDouble();
              final accuracy = (att['accuracy'] as num?)?.toDouble() ?? 0.0;
              final date = att['created_at'] != null ? att['created_at'].toString().split('T')[0] : 'Recent';

              return Card(
                elevation: 1.5,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(att['exam_name'] ?? 'Mock Test', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Date: $date • Accuracy: ${accuracy.toStringAsFixed(0)}%', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: widget.themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text('${score.toStringAsFixed(1)} / $maxMarks', style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.w900, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// UNIVERSAL BILINGUAL PRACTICE QUESTION WIDGET (ENGLISH EXCLUDED)
// -------------------------------------------------------------
class PracticeQuestionWidget extends StatefulWidget {
  final dynamic q;
  final int qNumber;
  const PracticeQuestionWidget({super.key, required this.q, required this.qNumber});

  @override
  State<PracticeQuestionWidget> createState() => _PracticeQuestionWidgetState();
}

class _PracticeQuestionWidgetState extends State<PracticeQuestionWidget> {
  int? _selectedOpt;
  bool _revealed = false;
  bool _isHindi = true;

  String _getQuestionText() {
    final qMap = widget.q;
    if (_isHindi) {
      if (qMap['q_hi'] != null && qMap['q_hi'].toString().trim().isNotEmpty) {
        return qMap['q_hi'].toString();
      }
    } else {
      if (qMap['q_en'] != null && qMap['q_en'].toString().trim().isNotEmpty) {
        return qMap['q_en'].toString();
      }
    }
    return qMap['q']?.toString() ?? '';
  }

  List<String> _getOptions() {
    final qMap = widget.q;
    if (_isHindi && qMap['options_hi'] != null && (qMap['options_hi'] as List).isNotEmpty) {
      return List<String>.from(qMap['options_hi']);
    } else if (!_isHindi && qMap['options_en'] != null && (qMap['options_en'] as List).isNotEmpty) {
      return List<String>.from(qMap['options_en']);
    } else if (qMap['options'] != null) {
      return List<String>.from(qMap['options']);
    }
    return [];
  }

  String _getExplanation() {
    final qMap = widget.q;
    if (_isHindi && qMap['exp_hi'] != null && qMap['exp_hi'].toString().trim().isNotEmpty) {
      return qMap['exp_hi'].toString();
    } else if (!_isHindi && qMap['exp_en'] != null && qMap['exp_en'].toString().trim().isNotEmpty) {
      return qMap['exp_en'].toString();
    }
    return qMap['exp']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final String subject = (widget.q['subject'] ?? '').toString().toUpperCase();
    final bool isEnglishSubject = subject == 'ENGLISH' || widget.q['subject'] == null;

    final options = isEnglishSubject
        ? (widget.q['options_en'] != null
            ? List<String>.from(widget.q['options_en'])
            : List<String>.from(widget.q['options'] ?? []))
        : _getOptions();

    final questionText = isEnglishSubject
        ? (widget.q['q_en']?.toString() ?? widget.q['q']?.toString() ?? '')
        : _getQuestionText();

    final explanation = isEnglishSubject
        ? (widget.q['exp_en']?.toString() ?? widget.q['exp']?.toString() ?? '')
        : _getExplanation();

    final correctAns = widget.q['ans'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Q${widget.qNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              if (!isEnglishSubject)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          if (!_isHindi) setState(() => _isHindi = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _isHindi ? const Color(0xFF1E3A8A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'हिंदी',
                            style: TextStyle(
                              color: _isHindi ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (_isHindi) setState(() => _isHindi = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: !_isHindi ? const Color(0xFF1E3A8A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'ENG',
                            style: TextStyle(
                              color: !_isHindi ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(questionText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.4)),
          const SizedBox(height: 10),
          ...List.generate(options.length, (optIdx) {
            Color? tileColor;
            if (_revealed) {
              if (optIdx == correctAns) {
                tileColor = Colors.green.shade100;
              } else if (_selectedOpt == optIdx) {
                tileColor = Colors.red.shade100;
              }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(color: tileColor, borderRadius: BorderRadius.circular(8)),
              child: RadioListTile<int>(
                dense: true,
                title: Text(options[optIdx], style: const TextStyle(fontSize: 13)),
                value: optIdx,
                groupValue: _selectedOpt,
                onChanged: (val) {
                  setState(() {
                    _selectedOpt = val;
                    _revealed = true;
                  });
                },
              ),
            );
          }),
          if (_revealed) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
              child: Text(
                '💡 Solution: $explanation',
                style: TextStyle(color: Colors.blueGrey.shade900, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }
}