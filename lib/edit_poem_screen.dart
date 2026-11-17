import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditPoemScreen extends StatefulWidget {
  final Map<String, dynamic> poem;

  const EditPoemScreen({super.key, required this.poem});

  @override
  State<EditPoemScreen> createState() => _EditPoemScreenState();
}

class _EditPoemScreenState extends State<EditPoemScreen> {
  final supabase = Supabase.instance.client;

  late TextEditingController titleController;
  late TextEditingController bodyController;
  late String language;

  Uint8List? imageBytes;
  bool removeImage = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.poem['title']);
    bodyController = TextEditingController(text: widget.poem['body']);
    language = widget.poem['language'] ?? 'Bangla';
  }

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    imageBytes = await image.readAsBytes();
    setState(() => removeImage = false);
  }

  Future<void> updatePoem() async {
    setState(() => loading = true);

    try {
      final user = supabase.auth.currentUser!;
      String? imageUrl = widget.poem['image_url'];

      if (removeImage) imageUrl = null;

      if (imageBytes != null) {
        final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage
            .from('poem-images')
            .uploadBinary(path, imageBytes!);

        imageUrl = supabase.storage.from('poem-images').getPublicUrl(path);
      }

      await supabase
          .from('poems')
          .update({
            'title': titleController.text.trim(),
            'body': bodyController.text.trim(),
            'language': language,
            'image_url': imageUrl,
          })
          .eq('id', widget.poem['id'])
          .eq('user_id', user.id);

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
    final oldImage = widget.poem['image_url'];

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Poem')),
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
              decoration: const InputDecoration(labelText: 'Poem Body'),
            ),
            const SizedBox(height: 20),
            if (imageBytes != null)
              Image.memory(imageBytes!, height: 200)
            else if (oldImage != null && !removeImage)
              Image.network(oldImage, height: 200),
            OutlinedButton.icon(
              onPressed: loading ? null : pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Change Picture'),
            ),
            if (oldImage != null || imageBytes != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    removeImage = true;
                    imageBytes = null;
                  });
                },
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
                onPressed: loading ? null : updatePoem,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Update Poem'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
