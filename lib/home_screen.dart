import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'settings_screen.dart';
import 'appColors.dart';
import 'add_poem_screen.dart';
import 'edit_poem_screen.dart';
import 'poem_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  String selectedLanguage = 'All';

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<void> deletePoem(String id) async {
    try {
      await supabase.from('poems').delete().eq('id', id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poem deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void openAddPoem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPoemScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AUDIYO',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: openAddPoem,
        backgroundColor: Appcolors.goldColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          Text(
            'Words from the soul.',
            style: GoogleFonts.lora(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Appcolors.navyColor,
            ),
          ),

          const SizedBox(height: 8),

          const Text('Discover creative words'),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              languageButton('All'),
              languageButton('Bangla'),
              languageButton('English'),
            ],
          ),

          const SizedBox(height: 15),

          Expanded(
            child: StreamBuilder(
              stream: supabase
                  .from('poems')
                  .stream(primaryKey: ['id'])
                  .order('created_at', ascending: false),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong!'));
                }

                final poems = snapshot.data ?? [];

                final filteredPoems = selectedLanguage == 'All'
                    ? poems
                    : poems
                          .where((poem) => poem['language'] == selectedLanguage)
                          .toList();

                if (filteredPoems.isEmpty) {
                  return const Center(child: Text('No poems found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPoems.length,

                  itemBuilder: (context, index) {
                    final poem = filteredPoems[index];

                    return Card(
                      color: Appcolors.cardColor,
                      margin: const EdgeInsets.only(bottom: 15),

                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PoemDetailScreen(poem: poem),
                            ),
                          );
                        },

                        child: Padding(
                          padding: const EdgeInsets.all(16),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (poem['image_url'] != null &&
                                  poem['image_url'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    poem['image_url'],
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox(
                                        height: 100,
                                        child: Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                              if (poem['image_url'] != null &&
                                  poem['image_url'].toString().isNotEmpty)
                                const SizedBox(height: 15),

                              Text(
                                poem['title'] ?? 'Untitled',
                                style: GoogleFonts.lora(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Appcolors.navyColor,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                poem['body'] ?? '',
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: Appcolors.textColor,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                poem['author_email'] ?? 'Unknown author',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    poem['language'] ?? '',
                                    style: const TextStyle(
                                      color: Appcolors.burgundyColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  if (poem['user_id'] ==
                                      supabase.auth.currentUser?.id)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditPoemScreen(poem: poem),
                                            ),
                                          );
                                        }

                                        if (value == 'delete') {
                                          deletePoem(poem['id']);
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit Poem'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete Poem'),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget languageButton(String language) {
    final selected = selectedLanguage == language;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedLanguage = language;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? Appcolors.navyColor : Appcolors.cardColor,
          foregroundColor: selected ? Colors.white : Appcolors.navyColor,
        ),
        child: Text(language),
      ),
    );
  }
}
