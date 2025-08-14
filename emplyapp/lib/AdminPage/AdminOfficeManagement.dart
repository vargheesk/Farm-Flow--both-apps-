import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AdminOfficeManagement extends StatefulWidget {
  const AdminOfficeManagement({super.key});

  @override
  State<AdminOfficeManagement> createState() => _AdminOfficeManagementState();
}

class _AdminOfficeManagementState extends State<AdminOfficeManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedState;
  String? selectedDistrict;
  String? selectedBlock;

  // Add controllers to maintain text field values
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _stateController.dispose();
    _districtController.dispose();
    _blockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Office Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add or Manage Offices',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStateField(),
                    const SizedBox(height: 24),
                    _buildDistrictField(),
                    const SizedBox(height: 24),
                    _buildBlockField(),
                    const SizedBox(height: 24),
                    _buildOfficeField(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'State',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TypeAheadField<String>(
          builder: (context, controller, focusNode) {
            // Use the class controller instead of the local one
            return TextField(
              controller: _stateController,
              focusNode: focusNode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select existing or enter new state',
              ),
            );
          },
          suggestionsCallback: (pattern) async {
            try {
              final states = await _firestore.collection('regions').get();
              return states.docs
                  .map((doc) => doc.id)
                  .where((state) =>
                      state.toLowerCase().contains(pattern.toLowerCase()))
                  .toList();
            } catch (e) {
              debugPrint('Error fetching states: $e');
              return [];
            }
          },
          itemBuilder: (context, state) => ListTile(title: Text(state)),
          onSelected: (state) => setState(() {
            selectedState = state;
            selectedDistrict = null;
            selectedBlock = null;
            // Update the text controller when a state is selected
            _stateController.text = state;
            _districtController.clear();
            _blockController.clear();
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add New State'),
                onPressed: () => _showAddDialog(
                  title: 'Add New State',
                  onAdd: (name) => _addState(name),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (selectedState != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Update State'),
                  onPressed: () => _showUpdateDialog(
                    title: 'Update State',
                    currentValue: selectedState!,
                    onUpdate: (newName) =>
                        _updateState(selectedState!, newName),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDistrictField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'District',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TypeAheadField<String>(
          builder: (context, controller, focusNode) {
            // Use the class controller instead of the local one
            return TextField(
              controller: _districtController,
              focusNode: focusNode,
              enabled: selectedState != null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select existing or enter new district',
              ),
            );
          },
          suggestionsCallback: (pattern) async {
            if (selectedState == null) return [];
            try {
              final districts = await _firestore
                  .collection('regions')
                  .doc(selectedState)
                  .collection('districts')
                  .get();
              return districts.docs
                  .map((doc) => doc.id)
                  .where((district) =>
                      district.toLowerCase().contains(pattern.toLowerCase()))
                  .toList();
            } catch (e) {
              debugPrint('Error fetching districts: $e');
              return [];
            }
          },
          itemBuilder: (context, district) => ListTile(title: Text(district)),
          onSelected: (district) => setState(() {
            selectedDistrict = district;
            selectedBlock = null;
            // Update the text controller when a district is selected
            _districtController.text = district;
            _blockController.clear();
          }),
        ),
        const SizedBox(height: 8),
        if (selectedState != null)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add New District'),
                  onPressed: () => _showAddDialog(
                    title: 'Add New District',
                    onAdd: (name) => _addDistrict(name),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              if (selectedDistrict != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Update District'),
                    onPressed: () => _showUpdateDialog(
                      title: 'Update District',
                      currentValue: selectedDistrict!,
                      onUpdate: (newName) =>
                          _updateDistrict(selectedDistrict!, newName),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildBlockField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Block',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TypeAheadField<String>(
          builder: (context, controller, focusNode) {
            // Use the class controller instead of the local one
            return TextField(
              controller: _blockController,
              focusNode: focusNode,
              enabled: selectedDistrict != null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select existing or enter new block',
              ),
            );
          },
          suggestionsCallback: (pattern) async {
            if (selectedState == null || selectedDistrict == null) return [];
            try {
              final blocks = await _firestore
                  .collection('regions')
                  .doc(selectedState)
                  .collection('districts')
                  .doc(selectedDistrict)
                  .collection('blocks')
                  .get();
              return blocks.docs
                  .map((doc) => doc.id)
                  .where((block) =>
                      block.toLowerCase().contains(pattern.toLowerCase()))
                  .toList();
            } catch (e) {
              debugPrint('Error fetching blocks: $e');
              return [];
            }
          },
          itemBuilder: (context, block) => ListTile(title: Text(block)),
          onSelected: (block) => setState(() {
            selectedBlock = block;
            // Update the text controller when a block is selected
            _blockController.text = block;
          }),
        ),
        const SizedBox(height: 8),
        if (selectedDistrict != null)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Block'),
                  onPressed: () => _showAddDialog(
                    title: 'Add New Block',
                    onAdd: (name) => _addBlock(name),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              if (selectedBlock != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Block'),
                    onPressed: () => _showUpdateDialog(
                      title: 'Update Block',
                      currentValue: selectedBlock!,
                      onUpdate: (newName) =>
                          _updateBlock(selectedBlock!, newName),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildOfficeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Office',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: selectedBlock != null
              ? _firestore
                  .collection('regions')
                  .doc(selectedState)
                  .collection('districts')
                  .doc(selectedDistrict)
                  .collection('blocks')
                  .doc(selectedBlock)
                  .collection('offices')
                  .snapshots()
              : null,
          builder: (context, snapshot) {
            if (selectedBlock == null) {
              return const Text(
                'Please select a block to manage offices',
                style: TextStyle(fontStyle: FontStyle.italic),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final offices = snapshot.data?.docs ?? [];

            if (offices.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No offices found in this block',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  _buildAddOfficeButton(),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: offices.length,
                  itemBuilder: (context, index) {
                    final office = offices[index];
                    final officeData = office.data() as Map<String, dynamic>;
                    final officeName = officeData['name'] as String;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(officeName),
                        subtitle: Text('ID: ${office.id}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showUpdateOfficeDialog(
                                officeId: office.id,
                                currentName: officeName,
                              ),
                              tooltip: 'Edit Office',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteConfirmation(
                                officeId: office.id,
                                officeName: officeName,
                              ),
                              tooltip: 'Delete Office',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildAddOfficeButton(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddOfficeButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text('Add New Office'),
      onPressed: selectedBlock != null
          ? () => _showAddDialog(
                title: 'Add New Office',
                onAdd: (name) => _addOffice(name),
              )
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _showAddDialog({
    required String title,
    required Future<void> Function(String) onAdd,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await onAdd(result);
        _showSnackBar('Added successfully');
      } catch (e) {
        _showSnackBar('Error: $e');
      }
    }
  }

  Future<void> _showUpdateDialog({
    required String title,
    required String currentValue,
    required Future<void> Function(String) onUpdate,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentValue) {
      try {
        await onUpdate(result);
        _showSnackBar('Updated successfully');
      } catch (e) {
        _showSnackBar('Error: $e');
      }
    }
  }

  Future<void> _showUpdateOfficeDialog({
    required String officeId,
    required String currentName,
  }) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Office'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentName) {
      try {
        await _updateOffice(officeId, result);
        _showSnackBar('Office updated successfully');
      } catch (e) {
        _showSnackBar('Error: $e');
      }
    }
  }

  Future<void> _showDeleteConfirmation({
    required String officeId,
    required String officeName,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content:
            Text('Are you sure you want to delete the office "$officeName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _deleteOffice(officeId);
        _showSnackBar('Office deleted successfully');
      } catch (e) {
        _showSnackBar('Error: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _addState(String name) async {
    await _firestore.collection('regions').doc(name).set({
      'name': name,
      'type': 'state',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    setState(() {
      selectedState = name;
      _stateController.text = name; // Update controller when adding new state
    });
  }

  Future<void> _updateState(String oldName, String newName) async {
    // Start a batch write
    final batch = _firestore.batch();

    // Get all districts under the old state
    final districts = await _firestore
        .collection('regions')
        .doc(oldName)
        .collection('districts')
        .get();

    // Create new state document
    batch.set(_firestore.collection('regions').doc(newName), {
      'name': newName,
      'type': 'state',
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Copy all districts to new state
    for (var district in districts.docs) {
      batch.set(
        _firestore
            .collection('regions')
            .doc(newName)
            .collection('districts')
            .doc(district.id),
        district.data(),
      );
    }

    // Delete old state document
    batch.delete(_firestore.collection('regions').doc(oldName));

    // Commit the batch
    await batch.commit();

    setState(() {
      selectedState = newName;
      _stateController.text = newName; // Update controller when updating state
    });
  }

  Future<void> _addDistrict(String name) async {
    if (selectedState == null) return;

    await _firestore
        .collection('regions')
        .doc(selectedState)
        .collection('districts')
        .doc(name)
        .set({
      'name': name,
      'type': 'district',
      'state': selectedState,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    setState(() {
      selectedDistrict = name;
      _districtController.text = name; // Update controller when adding district
    });
  }

  Future<void> _updateDistrict(String oldName, String newName) async {
    if (selectedState == null) return;

    final batch = _firestore.batch();

    // Get all blocks under the old district
    final blocks = await _firestore
        .collection('regions')
        .doc(selectedState)
        .collection('districts')
        .doc(oldName)
        .collection('blocks')
        .get();

    // Create new district document
    batch.set(
      _firestore
          .collection('regions')
          .doc(selectedState)
          .collection('districts')
          .doc(newName),
      {
        'name': newName,
        'type': 'district',
        'state': selectedState,
        'lastUpdated': FieldValue.serverTimestamp(),
      },
    );

    // Copy all blocks to new district
    for (var block in blocks.docs) {
      batch.set(
        _firestore
            .collection('regions')
            .doc(selectedState)
            .collection('districts')
            .doc(newName)
            .collection('blocks')
            .doc(block.id),
        block.data(),
      );
    }

    // Delete old district document
    batch.delete(
      _firestore
          .collection('regions')
          .doc(selectedState)
          .collection('districts')
          .doc(oldName),
    );

    await batch.commit();

    setState(() {
      selectedDistrict = newName;
      _districtController.text =
          newName; // Update controller when updating district
    });
  }

  Future<void> _addBlock(String name) async {
    if (selectedState == null || selectedDistrict == null) return;

    await _firestore
        .collection('regions')
        .doc(selectedState)
        .collection('districts')
        .doc(selectedDistrict)
        .collection('blocks')
        .doc(name)
        .set({
      'name': name,
      'type': 'block',
      'district': selectedDistrict,
      'state': selectedState,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    setState(() {
      selectedBlock = name;
      _blockController.text = name; // Update controller when adding block
    });
  }

  Future<void> _updateBlock(String oldName, String newName) async {
    if (selectedState == null || selectedDistrict == null) return;

    final batch = _firestore.batch();

    // Get all offices under the old block
    final offices = await _firestore
        .collection('regions')
        .doc(selectedState)
        .collection('districts')
        .doc(selectedDistrict)
        .collection('blocks')
        .doc(oldName)
        .collection('offices')
        .get();

    // Create new block document
    batch.set(
      _firestore
          .collection('regions')
          .doc(selectedState)
          .collection('districts')
          .doc(selectedDistrict)
          .collection('blocks')
          .doc(newName),
      {
        'name': newName,
        'type': 'block',
        'district': selectedDistrict,
        'state': selectedState,
        'lastUpdated': FieldValue.serverTimestamp(),
      },
    );

    // Copy all offices to new block
    for (var office in offices.docs) {
      batch.set(
        _firestore
            .collection('regions')
            .doc(selectedState)
            .collection('districts')
            .doc(selectedDistrict)
            .collection('blocks')
            .doc(newName)
            .collection('offices')
            .doc(office.id),
        office.data(),
      );
    }

    // Delete old block document
    batch.delete(
      _firestore
          .collection('regions')
          .doc(selectedState)
          .collection('districts')
          .doc(selectedDistrict)
          .collection('blocks')
          .doc(oldName),
    );

    await batch.commit();

    setState(() {
      selectedBlock = newName;
      _blockController.text = newName; // Update controller when updating block
    });
  }

  Future<void> _addOffice(String name) async {
    if (selectedState == null ||
        selectedDistrict == null ||
        selectedBlock == null) return;

    await _firestore
        .collection('regions')
        .doc(selectedState)
        .collection('districts')
        .doc(selectedDistrict)
        .collection('blocks')
        .doc(selectedBlock)
        .collection('offices')
        .add({
      'name': name,
      'type': 'office',
      'block': selectedBlock,
      'district': selectedDistrict,
      'state': selectedState,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateOffice(String officeId, String newName) async {
    if (selectedState == null ||
        selectedDistrict == null ||
        selectedBlock == null) return;

    await _firestore
        .collection('regions')
        .doc(selectedState)
        .collection('districts')
        .doc(selectedDistrict)
        .collection('blocks')
        .doc(selectedBlock)
        .collection('offices')
        .doc(officeId)
        .update({
      'name': newName,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteOffice(String officeId) async {
    if (selectedState == null ||
        selectedDistrict == null ||
        selectedBlock == null) return;

    await _firestore
        .collection('regions')
        .doc(selectedState)
        .collection('districts')
        .doc(selectedDistrict)
        .collection('blocks')
        .doc(selectedBlock)
        .collection('offices')
        .doc(officeId)
        .delete();
  }
}
