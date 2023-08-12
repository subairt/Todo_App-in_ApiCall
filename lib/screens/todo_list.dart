
import 'package:flutter/material.dart';
import 'package:todo_app/refactor/refactoring.dart';
import 'package:todo_app/screens/add_page.dart';
import 'package:todo_app/utils/snackbarhelper.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Todo List')),
      ),
      body: Visibility(
        visible: isLoading,
        child: const Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement:  Center(
              child: Text('No Todo Item',style: Theme.of(context).textTheme.headlineMedium,),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index] as Map;
                    final id = item['_id'] as String;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(item['title']),
                        subtitle: Text(item['description']),
                        trailing: PopupMenuButton(onSelected: (value) {
                          if (value == 'edit') {
                            //open edit page
                            navigateToEditPage(item); 
                          } else if (value == 'delete') {
                            //Delete and remove the item
                            deleteById(id);
                          }
                        }, itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              child: Text('Edit'),
                              value: 'edit',
                            ),
                            const PopupMenuItem(
                              child: Text('Delete'),
                              value: 'delete',
                            ),
                          ];
                        }),
                      ),
                    );
                  }),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: const Text('Add Todo'),
      ),
    );
  }
    Future<void> navigateToEditPage(Map item)async {
    final route = MaterialPageRoute(
      builder: (context) =>  AddTodoPage(todo: item),
    );
   await Navigator.push(context, route);
     setState(() {
     isLoading = true;
   });
   fetchTodo();
  }

  Future<void> navigateToAddPage()async{
    final route = MaterialPageRoute(
      builder: (context) => const AddTodoPage(),
    );
   await Navigator.push(context, route);
   setState(() {
     isLoading = true;
   });
   fetchTodo();
  }

  Future<void> deleteById(String id) async {
    //Delete the item
  
    final isSuccess = await TodoService.deleteById(id);
    if (isSuccess) {
      //Remove item from the list
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      //Show error
      // ignore: use_build_context_synchronously
      showErrorMessage(context,message: 'Deletion Failed');
    }
  }

  Future<void> fetchTodo() async {
     final response = await TodoService.fetchTodos();
    if (response != null) {
     
      setState(() {
        items = response;
      });
    }else{
      // ignore: use_build_context_synchronously
      showErrorMessage(context,message: 'Something Went to wrong');
    }
    setState(() {
      isLoading = false;
    });
  }

 
}
