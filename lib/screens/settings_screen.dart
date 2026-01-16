import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/wallpaper_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _usernameController;
  late String _initialApiKeyValue;
  late String _initialUsernameValue;
  bool _isVerifying = false;
  String? _verificationError;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _apiKeyController = TextEditingController(text: settings.apiKey);
    _usernameController = TextEditingController(text: settings.username);
    _initialApiKeyValue = settings.apiKey;
    _initialUsernameValue = settings.username;
    
    // 监听输入框变化，自动验证登录
    _apiKeyController.addListener(_onApiKeyChanged);
  }

  void _onApiKeyChanged() async {
    final currentValue = _apiKeyController.text.trim();
    
    // 如果输入框为空或与初始值相同，清除错误状态
    if (currentValue.isEmpty || currentValue == _initialApiKeyValue) {
      if (_verificationError != null) {
        setState(() {
          _verificationError = null;
        });
      }
      return;
    }

    // API Key 通常至少32个字符，等待用户输入完成
    if (currentValue.length < 20) {
      return;
    }

    // 防抖：等待用户停止输入500ms后再验证
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 检查输入框内容是否已改变（用户可能继续输入）
    if (_apiKeyController.text.trim() != currentValue) {
      return;
    }

    // 开始验证
    if (mounted && !_isVerifying) {
      setState(() {
        _isVerifying = true;
        _verificationError = null;
      });

      try {
        // 先更新API key到provider
        context.read<WallpaperProvider>().api.updateApiKey(currentValue);
        
        // 验证登录
        await context.read<WallpaperProvider>().syncApiKey(currentValue);
        
        // 验证成功，保存到本地
        if (mounted) {
          await context.read<SettingsProvider>().setApiKey(currentValue);
          setState(() {
            _isVerifying = false;
            _verificationError = null;
            _initialApiKeyValue = currentValue; // 更新初始值
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isVerifying = false;
            _verificationError = e.toString();
          });
          // 验证失败，清除API key
          context.read<WallpaperProvider>().api.updateApiKey(null);
        }
      }
    }
  }

  @override
  void dispose() {
    _apiKeyController.removeListener(_onApiKeyChanged);
    // 如果用户修改了 API Key 但验证失败，在离开设置页时恢复初始值
    final currentValue = _apiKeyController.text.trim();
    if (currentValue != _initialApiKeyValue && _verificationError != null) {
      // 验证失败，恢复初始值
      context.read<WallpaperProvider>().api.updateApiKey(_initialApiKeyValue.isEmpty ? null : _initialApiKeyValue);
    }
    // 保存用户名
    final currentUsername = _usernameController.text.trim();
    if (currentUsername != _initialUsernameValue) {
      context.read<SettingsProvider>().setUsername(currentUsername);
    }
    _apiKeyController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Login / API Key Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.loginApiKey,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apiKeyController,
                    decoration: InputDecoration(
                      labelText: l10n.apiKey,
                      hintText: l10n.enterApiKey,
                      border: const OutlineInputBorder(),
                      suffixIcon: _isVerifying
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _verificationError != null
                              ? const Icon(Icons.error, color: Colors.red)
                              : _apiKeyController.text.trim().isNotEmpty &&
                                      _apiKeyController.text.trim() != _initialApiKeyValue &&
                                      _verificationError == null
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : null,
                      errorText: _verificationError != null
                          ? (_verificationError!.contains('401') || _verificationError!.contains('Unauthorized')
                              ? 'Invalid API Key'
                              : 'Verification failed')
                          : null,
                    ),
                  ),
                  if (_isVerifying)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Verifying API Key...',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  if (_verificationError == null &&
                      _apiKeyController.text.trim().isNotEmpty &&
                      _apiKeyController.text.trim() != _initialApiKeyValue &&
                      !_isVerifying)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'API Key verified successfully',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: l10n.username,
                      hintText: l10n.enterUsername,
                      border: const OutlineInputBorder(),
                      helperText: l10n.usernameRequiredForCollections,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final key = _apiKeyController.text.trim();
                        final username = _usernameController.text.trim();
                        
                        // Save API Key and Username
                        await context
                            .read<SettingsProvider>()
                            .setApiKey(key);
                        await context
                            .read<SettingsProvider>()
                            .setUsername(username);

                        if (context.mounted) {
                          try {
                            await context.read<WallpaperProvider>().updateApiKey(key);
                            if (context.mounted) {
                              // 更新初始值，避免dispose时重复保存
                              _initialApiKeyValue = key;
                              _initialUsernameValue = username;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.saved)),
                              );
                            }
                          } catch (e) {
                             if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Invalid API Key or Network Error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Download Path Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.downloadPath,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(settings.downloadPath ?? l10n.defaultDownloadsFolder),
                    subtitle: Text(l10n.tapIconToChange),
                    trailing: IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: () async {
                        String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                        if (selectedDirectory != null) {
                          if (context.mounted) {
                            await context.read<SettingsProvider>().setDownloadPath(selectedDirectory);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Language Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.language,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: settings.locale.languageCode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'zh', child: Text('中文')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        context
                            .read<SettingsProvider>()
                            .setLocale(Locale(value));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Theme Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.theme,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ThemeMode>(
                    initialValue: settings.themeMode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: ThemeMode.system, child: Text('System')),
                      DropdownMenuItem(
                          value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(
                          value: ThemeMode.dark, child: Text('Dark')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsProvider>().setThemeMode(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
