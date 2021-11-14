import 'package:flutter/material.dart';
import 'package:text_form_field_wrapper/text_form_field_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    TextFormField formField = TextFormField(
      initialValue: '',
      decoration: const InputDecoration(border: InputBorder.none),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Form Field Wrapper'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // spacer
                  const SizedBox(height: 20),

                  // Example of TextFormFieldWrapper with position 'alone'
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Text('Standalone field with no suffix or prefix'),
                  ),
                  TextFormFieldWrapper(
                    formField: formField,
                    position: TextFormFieldPosition.alone,
                  ),

                  // spacer
                  const SizedBox(height: 20),

                  // Example of TextFormFieldWrapper with position 'alone'
                  // and with a prefix Widget
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Text('Standalone field with prefix only'),
                  ),
                  TextFormFieldWrapper(
                    formField: formField,
                    position: TextFormFieldPosition.alone,
                    prefix: const Text('Prefix'),
                  ),

                  // spacer
                  const SizedBox(height: 20),

                  // Example of TextFormFieldWrapper with position 'alone'
                  // and with a suffix Widget
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Text('Standalone field with suffix only'),
                  ),
                  TextFormFieldWrapper(
                    formField: formField,
                    position: TextFormFieldPosition.alone,
                    suffix: const Text('Suffix'),
                  ),

                  // spacer
                  const SizedBox(height: 20),

                  // Example of TextFormFieldWrapper with position 'alone'
                  // and with a prefix Widget and suffix
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Text('Standalone field with prefix and suffix'),
                  ),
                  TextFormFieldWrapper(
                    formField: formField,
                    position: TextFormFieldPosition.alone,
                    prefix: const Text('Prefix'),
                    suffix: const Text('Suffix'),
                  ),

                  // spacer
                  const SizedBox(height: 20),

                  // Example of TextFormFieldWrappers side by side
                  // One TextFormFieldWrapper has the position 'left' and the
                  // other has the position 'right'
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Text('Two fields side by side'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormFieldWrapper(
                          formField: formField,
                          position: TextFormFieldPosition.left,
                        ),
                      ),
                      Expanded(
                        child: TextFormFieldWrapper(
                          formField: formField,
                          position: TextFormFieldPosition.right,
                        ),
                      ),
                    ],
                  ),

                  // spacer
                  const SizedBox(height: 20),

                  // Example of TextFormFieldWrappers stacked ontop of each other
                  // with position 'top', 'center' and 'bottom'
                  // where the widget is sandwiched between a widget above
                  // and a widget below
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Text('Multiple fields stacked ontop of another'),
                  ),
                  Column(
                    children: [
                      TextFormFieldWrapper(
                        formField: formField,
                        position: TextFormFieldPosition.top,
                      ),
                      TextFormFieldWrapper(
                        formField: formField,
                        position: TextFormFieldPosition.center,
                      ),
                      TextFormFieldWrapper(
                        formField: formField,
                        position: TextFormFieldPosition.bottom,
                      ),
                    ],
                  ),

                  // spacer
                  const SizedBox(height: 20),

                  // Example of TextFormFieldWrappers in a grid like setup
                  // with positions 'top','bottomLeft' and 'bottomRight'
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Text(
                        'Collection of textfield to mimic credit card input'),
                  ),
                  Column(
                    children: [
                      TextFormFieldWrapper(
                        formField: TextFormField(
                          initialValue: '',
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                              hintText: '1234 1234 1234 1234',
                              hintStyle:
                                  TextStyle(letterSpacing: 6, fontSize: 18),
                              border: InputBorder.none),
                        ),
                        position: TextFormFieldPosition.top,
                        suffix: const Icon(Icons.credit_card),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormFieldWrapper(
                              formField: TextFormField(
                                initialValue: '',
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                    hintText: 'MM/YY',
                                    hintStyle: TextStyle(
                                        letterSpacing: 6, fontSize: 18),
                                    border: InputBorder.none),
                              ),
                              position: TextFormFieldPosition.bottomLeft,
                            ),
                          ),
                          Expanded(
                            child: TextFormFieldWrapper(
                              formField: TextFormField(
                                initialValue: '',
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                    hintText: 'CVV',
                                    hintStyle: TextStyle(
                                        letterSpacing: 6, fontSize: 18),
                                    border: InputBorder.none),
                              ),
                              position: TextFormFieldPosition.bottomRight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 80,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
