// Odooligin function
void loginToOdoo() async {
  final orpc = OdooClient(serverAddress); // add serveraddress

  try {
    final uid = await orpc.authenticate(
      db_name,
      _emailController.text, // Add Username
      _passwordController.text, // AddPassword
    );

    // log('Successfully logged in with UID: $uid');
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Success login')));

    // Navigate to the next screen or perform other actions upon successful login

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => UserProfileScreen(uid)),
      (route) => false,
    );
  } catch (e) {
    log('Login failed: $e');
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')));
    // Handle login failure (show error message, etc.)
  }
}

// odoo Get data list function
Future<dynamic> fetchContacts() async {
  await orpc.authenticate('dbname', 'username', 'password');
  dynamic res = await orpc.callKw({
    'model': '', //add  table name
    'method': 'search_read', // this is get user data
    'args': [],
    'kwargs': {
      'context': {'bin_size': true},
      'domain': [],
      'fields': [
        'name',
        'login',
        'login_date',

        // can add another fields in table
      ],
      // 'limit': 100,
    },
  });
  log("ResultData>>> $res");

  return res;
}

// get data by id function

Future<void> fetchData() async {
  // this fun need to require to call in set state
  try {
    // Call the method to fetch data
    dynamic result = await fetchContactById(); // add user id

    // Update the state with the fetched data
    setState(() {
      userData = result;
    });
  } catch (error) {
    // Handle errors if necessary
    log("Error fetching data: $error");
  }
}

final orpc = OdooClient(serverAddress); // add serveraddress

Future<dynamic> fetchContactById(String? userId) async {
  // log("ResultData for user with ID $userId");
  await orpc.authenticate(db_name, user_name, passwrd);
  dynamic res = await orpc.callKw({
    'model': '', // add table name
    'method': 'search_read', // this is get data method
    'args': [
      [
        ['id', '=', userId] // call data with id
      ]
    ],
    'kwargs': {
      'context': {'bin_size': true},
      'fields': [
        'name',
        'login',
        'login_date',
        'lang',
        'company_id',
      ],
    },
    'join': [
      [
        'res.company',
        '=',
        'res.users.companyId'
      ], // this is join table to table with id
    ],
  });
  log("ResultData for user with ID  $res");

  return res;
}

// create data in odoo function
void odooReg(String? email, String? password) async {
  final OdooClient client = OdooClient(serverAddress);

  try {
    await client.authenticate(db_name, user_name, passwrd);

    final int userId = await client.callKw({
      'model': '', // add table name
      'method': 'create',
      'args': [
        {
          'name': email,
          'login': email,
          'password': password,
        },
      ],
      'kwargs': {},
    });
    log('message');

    // final int userId = result[0] as int;

    log('New user created with ID: $userId');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ScreenName()),
      (route) => false,
    );
  } catch (e) {
    log('Error: $e');
  }
}

// email valdation check
final RegExp _emailRegExp = RegExp(
  r'^[a-zA-Z0-9.-_]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$',
);

bool _validateEmail(BuildContext context, String email) {
  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter an email address'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  } else if (!_emailRegExp.hasMatch(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid email format'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
  return true;
}
