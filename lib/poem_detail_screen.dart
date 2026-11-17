import 'package:flutter/material.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'appColors.dart';
import 'main.dart';

class PoemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> poem;

  const PoemDetailScreen({super.key, required this.poem});

  @override
  State<PoemDetailScreen> createState() => _PoemDetailScreenState();
}

class _PoemDetailScreenState extends State<PoemDetailScreen> {
  final commentController = TextEditingController();

  Future<void> addComment() async {
    if (commentController.text.trim().isEmpty) return;

    final user = supabase.auth.currentUser!;

    try {
      await supabase.from('comments').insert({
        'poem_id': widget.poem['id'],
        'user_id': user.id,
        'user_email': user.email,
        'content': commentController.text.trim(),
      });

      commentController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Comment added!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final poem = widget.poem;

    return Scaffold(
      appBar: AppBar(title: const Text('Poem Details')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poem['title'] ?? 'Untitled',
              style: GoogleFonts.lora(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Appcolors.navyColor,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'By ${poem['author_email'] ?? 'Unknown'}',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            Text(
              poem['body'] ?? '',
              style: poemTextStyle(poem['language'] ?? 'English', fontSize: 18),
            ),

            const SizedBox(height: 30),

            const Divider(),

            Text(
              'Comments',
              style: GoogleFonts.lora(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Appcolors.navyColor,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                suffixIcon: IconButton(
                  onPressed: addComment,
                  icon: const Icon(Icons.send),
                ),
              ),
            ),

            const SizedBox(height: 20),

            StreamBuilder(
              stream: supabase
                  .from('comments')
                  .stream(primaryKey: ['id'])
                  .eq('poem_id', poem['id'])
                  .order('created_at'),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text('Could not load comments.');
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return const Text('No comments yet.');
                }

                return Column(
                  children: comments.map((comment) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(comment['user_email'] ?? 'User'),
                      subtitle: Text(comment['content'] ?? ''),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
