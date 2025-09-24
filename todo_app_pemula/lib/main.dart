import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan import ini untuk HapticFeedback

// Model class untuk Task = blueprint/template untuk objek Task
class Task {
  // Property untuk menyimpan judul task
  String title;
  // Property untuk menyimpan status selesai/belum
  bool isCompleted;

  // Constructor = function untuk membuat Task baru
  Task({
    // title wajib diisi (required)
    required this.title,
    // isCompleted opsional, default false (belum selesai)
    this.isCompleted = false,
  });

  // Method untuk toggle status completed (true ↔ false)
  void toggle() {
    // Flip boolean: true jadi false, false jadi true
    isCompleted = !isCompleted;
  }

  // Override toString untuk debug print yang readable
  @override
  String toString() {
    return 'Task{title: $title, isCompleted: $isCompleted}';
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App Pemula',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

// StatefulWidget untuk TodoListScreen
class TodoListScreen extends StatefulWidget {
  // Override method untuk membuat state object
  @override
  // Function yang return instance dari state class
  _TodoListScreenState createState() => _TodoListScreenState();
}

// State class yang menyimpan data dan build UI
class _TodoListScreenState extends State<TodoListScreen> {
  // List untuk menyimpan objek Task (bukan String lagi)
  List<Task> tasks = [];
  // Controller untuk mengontrol TextField (ambil text, clear, dll)
  TextEditingController taskController = TextEditingController();

  // Function untuk menambah task baru ke dalam list
  // Function addTask dengan validasi comprehensive dan feedback
  void addTask() {
    // Ambil dan bersihkan input text
    String newTaskTitle = taskController.text.trim();

    // Validasi 1: Cek apakah input kosong
    if (newTaskTitle.isEmpty) {
      // Tampilkan SnackBar warning untuk input kosong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Content dengan icon dan text
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Task tidak boleh kosong!'),
            ],
          ),
          // Styling SnackBar
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Stop execution jika gagal validasi
      return;
    }

    // Validasi 2: Cek task duplikat (case insensitive)
    bool isDuplicate = tasks.any((task) =>
        task.title.toLowerCase() == newTaskTitle.toLowerCase());

    if (isDuplicate) {
      // SnackBar untuk task duplikat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info, color: Colors.white),
              SizedBox(width: 8),
              // Expanded agar text tidak overflow
              Expanded(child: Text('Task "$newTaskTitle" sudah ada!')),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validasi 3: Cek panjang task maksimal 100 karakter
    if (newTaskTitle.length > 100) {
      // SnackBar untuk task terlalu panjang
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Task terlalu panjang! Maksimal 100 karakter.')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Semua validasi passed - add task
    setState(() {
      Task newTask = Task(title: newTaskTitle);
      tasks.add(newTask);
    });

    // Clear input
    taskController.clear();

    // Success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Task "$newTaskTitle" berhasil ditambahkan!')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    print('Task ditambahkan: $newTaskTitle');
  }

  // Function async untuk menghapus task dengan konfirmasi dialog
  void removeTask(int index) async {
    // Simpan objek Task yang akan dihapus untuk ditampilkan di dialog
    Task taskToDelete = tasks[index];

    // Tampilkan dialog konfirmasi dan tunggu response user
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Better Dialog Styling
          title: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Konfirmasi Hapus'),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apakah kamu yakin ingin menghapus task ini?'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${taskToDelete.title}"', // Akses .title property
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );

    // Cek apakah user pilih hapus (shouldDelete == true)
    if (shouldDelete == true) {
      setState(() {
        tasks.removeAt(index); // Hapus dari list
      });

      // Success feedback for delete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Task "${taskToDelete.title}" dihapus')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      print('Task dihapus: ${taskToDelete.title}');
      print('Sisa tasks: ${tasks.length}');
    } else {
      print('Delete dibatalkan');
    }
  }

  // Function untuk toggle status completed
  void toggleTask(int index) {
    setState(() {
      tasks[index].toggle();
    });

    Task task = tasks[index];
    String message = task.isCompleted
        ? 'Selamat! Task "${task.title}" selesai! 🎉'
        : 'Task "${task.title}" ditandai belum selesai';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              task.isCompleted ? Icons.celebration : Icons.undo,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: task.isCompleted ? Colors.green : Colors.blue,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    print('Task ${task.isCompleted ? "completed" : "uncompleted"}: ${task.title}');
  }

  // Helper function untuk statistic items
  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Override method build untuk membuat UI
  @override
  Widget build(BuildContext context) {
    // Return UI yang sama seperti Tahap 2
    return Scaffold(
      // AppBar di bagian atas
      appBar: AppBar(
        title: Text('My To-Do List'),
        backgroundColor: Colors.blue,
      ),
      // Body dengan padding di semua sisi
      body: Padding(
        padding: EdgeInsets.all(16.0),
        // Column untuk layout vertikal
        child: Column(
          children: [
            // Container untuk area input form
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
              ),
              // Column di dalam container
              child: Column(
                children: [
                  // Input field untuk ketik task
                  TextField(
                    // Hubungkan dengan controller untuk kontrol text
                    controller: taskController,
                    textCapitalization: TextCapitalization.sentences, // Auto capitalize
                    maxLength: 100, // Limit input length
                    // Styling dan dekorasi input
                    decoration: InputDecoration(
                      hintText: 'Ketik task baru di sini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(Icons.edit),
                      counterText: '', // Hide character counter
                      helperText: 'Maksimal 100 karakter', // Helper text
                    ),
                    onSubmitted: (value) => addTask(), // Enter key also adds task
                  ),
                  // Jarak vertikal
                  SizedBox(height: 12),
                  // Container untuk button
                  SizedBox(
                    width: double.infinity,
                    // Button untuk add task
                    child: ElevatedButton(
                      // Panggil function addTask saat button ditekan
                      onPressed: addTask,
                      // Styling button
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      // Isi button: Row untuk susun icon dan text horizontal
                      child: Row(
                        // Posisi elemen di tengah Row
                        mainAxisAlignment: MainAxisAlignment.center,
                        // Daftar widget dalam Row
                        children: [
                          // Icon plus
                          Icon(Icons.add),
                          // Jarak horizontal 8 pixel antara icon dan text
                          SizedBox(width: 8),
                          // Text button
                          Text(
                            'Add Task',
                            // Styling text
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Jarak vertikal
            SizedBox(height: 20),
            // Tambahkan statistik card di sini
            if (tasks.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Statistik Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Total', tasks.length, Icons.list, Colors.blue),
                        _buildStatItem(
                          'Selesai',
                          tasks.where((task) => task.isCompleted).length,
                          Icons.check_circle,
                          Colors.green
                        ),
                        _buildStatItem(
                          'Belum',
                          tasks.where((task) => !task.isCompleted).length,
                          Icons.pending,
                          Colors.orange
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // Text yang menampilkan jumlah tasks
            Text(
              tasks.isEmpty
                ? 'Belum ada task. Yuk tambah yang pertama!'
                : 'Kamu punya ${tasks.length} task${tasks.length > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 16,
                color: tasks.isEmpty ? Colors.grey[600] : Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            // Jarak vertikal sebelum area list
            SizedBox(height: 20),
            // Expanded mengambil sisa ruang yang tersedia di Column
            Expanded(
              // Container untuk styling area list
              child: Container(
                // Lebar penuh
                width: double.infinity,
                // Padding di dalam container
                padding: EdgeInsets.all(16),
                // Dekorasi container: border dan border radius
                decoration: BoxDecoration(
                  // Border abu-abu di sekeliling
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  // Sudut melengkung
                  borderRadius: BorderRadius.circular(12.0),
                ),
                // Isi container: placeholder text di tengah
                child: tasks.isEmpty
                  ? // Tampilan jika list kosong
                    Center(
                      // Column untuk susun icon dan text vertikal
                      child: Column(
                        // Center semua content di tengah
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon inbox kosong
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          // Jarak vertikal
                          SizedBox(height: 16),
                          // Text utama
                          Text(
                            'Belum ada task',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          // Jarak kecil
                          SizedBox(height: 8),
                          // Text penjelasan
                          Text(
                            'Tambahkan task pertamamu di atas!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : // Tampilan jika ada tasks: ListView untuk scroll
                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        Task task = tasks[index]; // Ambil Task object

                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              // Background berubah berdasarkan status
                              color: task.isCompleted ? Colors.green[50] : Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: task.isCompleted
                                  ? Border.all(color: Colors.green[200]!, width: 2) // Border hijau jika selesai
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Opacity(
                              opacity: task.isCompleted ? 0.7 : 1.0, // Completed task lebih transparan
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    // Warna berubah berdasarkan status
                                    color: task.isCompleted ? Colors.green[100] : Colors.blue[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: task.isCompleted
                                        ? Icon(Icons.check, color: Colors.green[700]) // Icon check jika selesai
                                        : Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                                title: Text(
                                  task.title, // Akses .title dari Task object
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: task.isCompleted ? Colors.grey[600] : Colors.black87,
                                    // STRIKETHROUGH untuk completed task
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Text(
                                  task.isCompleted ? 'Selesai ✅' : 'Belum selesai',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: task.isCompleted ? Colors.green[600] : Colors.grey[600],
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // CHECKBOX untuk toggle complete
                                    IconButton(
                                      icon: Icon(
                                        task.isCompleted
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: task.isCompleted ? Colors.green[600] : Colors.grey[400],
                                      ),
                                      onPressed: () => toggleTask(index),
                                      tooltip: task.isCompleted
                                          ? 'Mark as incomplete'
                                          : 'Mark as complete',
                                    ),
                                    // Delete button
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                                      onPressed: () => removeTask(index),
                                      tooltip: 'Hapus task',
                                    ),
                                  ],
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                // Tap pada item juga bisa toggle
                                onTap: () => toggleTask(index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}