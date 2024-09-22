import 'package:flutter/material.dart';
import 'vote.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<Vote> _votes = [
    Vote(option: 'BJP', icon: Icons.thumb_up, count: 10),
    Vote(option: 'Congress', icon: Icons.thumb_down, count: 8),
    Vote(option: 'Aam Aadmi Party', icon: Icons.star, count: 5),
  ];

  final TextEditingController _optionController = TextEditingController();

  void _addVoteOption() {
    final String optionText = _optionController.text.trim();
    if (optionText.isEmpty) {
      return; // Option name cannot be empty
    }
    setState(() {
      _votes.add(Vote(option: optionText, icon: Icons.info, count: 0)); // Default icon and count
    });
    _optionController.clear();
    Navigator.of(context).pop(); // Close the dialog
  }

  void _removeVoteOption(int index) {
    setState(() {
      _votes.removeAt(index);
    });
  }

  void _showAddOptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Voting Option'),
          content: TextField(
            controller: _optionController,
            decoration: InputDecoration(hintText: 'Enter option name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: _addVoteOption,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _votes.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                leading: Icon(
                  _votes[index].icon,
                  size: 40.0,
                  color: Colors.teal,
                ),
                title: Text(
                  _votes[index].option,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${_votes[index].count} votes'),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeVoteOption(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptionDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
