import 'package:flutter/material.dart';
import '../services/timezone_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currentCountry = 'South Korea';

  @override
  void initState() {
    super.initState();
    _loadCurrentCountry();
  }

  Future<void> _loadCurrentCountry() async {
    final country = await TimezoneService.getCurrentCountry();
    setState(() {
      _currentCountry = country;
    });
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
    );
    const subtitleStyle = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.normal,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.black87),
            title: const Text('Login', style: textStyle),
            subtitle:
                const Text('Sign in to sync your data', style: subtitleStyle),
            onTap: () {
              // TODO: 로그인 화면으로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.public, color: Colors.black87),
            title: const Text('Time Zone', style: textStyle),
            subtitle: Text('Current: $_currentCountry',
                style: const TextStyle(color: Colors.black)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'Select Your Country',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          title: const Text('South Korea (UTC+9)',
                              style: textStyle),
                          onTap: () async {
                            await TimezoneService.setTimezoneOffset(
                                9, 'South Korea');
                            if (context.mounted) {
                              setState(() {
                                _currentCountry = 'South Korea';
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Timezone set to UTC+9')),
                              );
                            }
                          },
                        ),
                        ListTile(
                          title: const Text('United States (EST, UTC-5)',
                              style: textStyle),
                          onTap: () async {
                            await TimezoneService.setTimezoneOffset(
                                -5, 'United States');
                            if (context.mounted) {
                              setState(() {
                                _currentCountry = 'United States';
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Timezone set to UTC-5')),
                              );
                            }
                          },
                        ),
                        ListTile(
                          title: const Text('Japan (UTC+9)', style: textStyle),
                          onTap: () {
                            // TODO: 일본 시간대 설정
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('China (UTC+8)', style: textStyle),
                          onTap: () {
                            // TODO: 중국 시간대 설정
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
