import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddPoemScreen extends StatefulWidget {
  const AddPoemScreen({super.key});

  @override
  State<AddPoemScreen> createState() => _AddPoemScreenState();
}

class _AddPoemScreenState extends State<AddPoemScreen> {
  final supabase = Supabase.instance.client;
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  String language = 'Bangla';
  bool loading = false;
  Uint8List? imageBytes;

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    imageBytes = await image.readAsBytes();
    setState(() {});
  }

  Future<void> publishPoem() async {
    if (titleController.text.trim().isEmpty ||
        bodyController.text.trim().isEmpty) {
      return;
    }

    setState(() => loading = true);

    try {
      final user = supabase.auth.currentUser!;
      String? imageUrl;

      if (imageBytes != null) {
        final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage
            .from('poem-images')
            .uploadBinary(path, imageBytes!);

        imageUrl = supabase.storage.from('poem-images').getPublicUrl(path);
      }

      await supabase.from('poems').insert({
        'user_id': user.id,
        'author_email': user.email,
        'title': titleController.text.trim(),
        'body': bodyController.text.trim(),
        'language': language,
        'image_url': imageUrl,
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write a Poem')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Poem Title'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: bodyController,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: 'Write your poem...',
              ),
            ),
            const SizedBox(height: 20),
            if (imageBytes != null) Image.memory(imageBytes!, height: 200),
            OutlinedButton.icon(
              onPressed: loading ? null : pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Add Picture (Optional)'),
            ),
            if (imageBytes != null)
              TextButton(
                onPressed: () => setState(() => imageBytes = null),
                child: const Text('Remove Picture'),
              ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: language,
              decoration: const InputDecoration(labelText: 'Language'),
              items: const [
                DropdownMenuItem(value: 'Bangla', child: Text('Bangla')),
                DropdownMenuItem(value: 'English', child: Text('English')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => language = value);
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loading ? null : publishPoem,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Publish Poem'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
