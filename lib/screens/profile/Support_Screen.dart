import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "How can we help you?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // FAQs Section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: const Icon(Icons.question_answer, color: Colors.green),
              title: const Text("Frequently Asked Questions"),
              children: const [
                ListTile(
                  title: Text("How do I place an order?"),
                  subtitle: Text(
                      "Go to the vegetables section, add items to your cart, and proceed to checkout."),
                ),
                ListTile(
                  title: Text("What payment methods are accepted?"),
                  subtitle: Text("We accept Cash on Delivery and Credit/Debit Cards."),
                ),
                ListTile(
                  title: Text("Can I cancel an order?"),
                  subtitle: Text(
                      "Yes, you can cancel your order before it is packed."),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Contact Options
          const Text(
            "Contact Us",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text("Call Us"),
              subtitle: const Text("+92 300 1234567"),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text("Email Us"),
              subtitle: const Text("support@freshcart.com"),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat, color: Colors.orange),
              title: const Text("Live Chat"),
              subtitle: const Text("Chat with our support team"),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 20),

          // Feedback
          const Text(
            "Send Feedback",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Write your feedback here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.send),
            label: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
