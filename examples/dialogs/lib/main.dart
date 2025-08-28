import 'package:flutter/material.dart';
import 'package:pkg_toolbox/toolbox.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ElevatedButton(
              // elevated button
              onPressed: () async {
                bool? bResult = await DialogBuilder<bool>(
                  context: context,
                  //dimissible: false,
                  message:
                      'Ceci est un message d\'information pour notifier l\'utilisateur.',
                  altMessage: const Row(
                    children: [
                      Icon(
                        Icons.info_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),
                      Flexible(
                        child: Text(
                          "C'est beau de rêver, mais il faut se réveiller pour que les rêves se réalisent",
                          style: TextStyle(color: Colors.grey),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  tag: 'diag1',
                ).ok();
                switch (bResult) {
                  case true:
                    debugPrint("return OK");
                    break;
                  default:
                    debugPrint("return null");
                    break;
                }
              },
              child: const Text("OK"),
            ),
            ElevatedButton(
              // elevated button
              onPressed: () async {
                bool? bResult = await DialogBuilder<bool>(
                  context: context,
                  message: 'Plus de pile dans l\'ordinateur.',
                  altMessage:
                      "Ou branchez cet ordinateur sur une prise.\n- soit avec un adapteur secteur, - soit avec un adaptateur 12V sur l'allume-cigare de votre véhicule.",
                ).warning();
                switch (bResult) {
                  case true:
                    debugPrint("return OK");
                    break;
                  default:
                    debugPrint("return null");
                    break;
                }
              },
              child: const Text("Warning"),
            ),
            ElevatedButton(
              // elevated button
              onPressed: () async {
                bool? bResult = await DialogBuilder<bool>(
                  context: context,
                  message: FittedBox(
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            const VerticalDivider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  'https://c7.alamy.com/compfr/arhy3r/clavier-ordinateur-gravure-arhy3r.jpg',
                                  width: 200,
                                  height: 200,
                                ),
                                const Text('Votre clavier est en feu.'),
                                const Text(
                                  'L\'ordinateur va exploser.',
                                ),
                                const Text('Sortez vite !',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).error();
                switch (bResult) {
                  case true:
                    debugPrint("return OK");
                    break;
                  default:
                    debugPrint("return null");
                    break;
                }
              },
              child: const Text("Erreur"),
            ),
            ElevatedButton(
              // elevated button
              onPressed: () async {
                bool? bResult = await DialogBuilder<bool>(
                        context: context,
                        shuffleButtons: true,
                        tag: 'diag2',
                        message:
                            'Cette action va installer un virus sur votre ordinateur.\nVoulez-vous continuer ?')
                    .yesNo();
                switch (bResult) {
                  case true:
                    debugPrint("return OK");
                    break;
                  case false:
                    debugPrint("retrun Cancel");
                    break;
                  default:
                    debugPrint("return null");
                    break;
                }
              },
              child: const Text("Oui / Non"),
            ),
            ElevatedButton(
              // elevated button
              onPressed: () async {
                bool? bResult = await DialogBuilder<bool>(
                        context: context,
                        tag: 'diag3',
                        message: 'Supprimer cet utilisateur ?')
                    .removeCancel();
                switch (bResult) {
                  case true:
                    debugPrint("return OK");
                    break;
                  case false:
                    debugPrint("retrun Cancel");
                    break;
                  default:
                    debugPrint("return null");
                    break;
                }
              },
              child: const Text("Supprimer"),
            ),
            ElevatedButton(
              // elevated button
              onPressed: () async {
                int? nResult = await DialogBuilder<int>(
                  context: context,
                  message: 'Température du bureau ?',
                  altMessage: 'Très important pour le confort de tous.',
                  icon: const Icon(
                    Icons.ac_unit,
                    color: Colors.blue,
                    size: 40,
                  ),
                ).custom(dialogButtons: [
                  DialogButton(label: "Froid", value: 1),
                  DialogButton(label: "Parfait", value: 2, isDefault: true),
                  DialogButton(label: "Chaud", value: 3),
                ], type: DialogType.question);
                switch (nResult) {
                  case 1:
                    debugPrint("Froid");
                    break;
                  case 2:
                    debugPrint("Parfait");
                    break;
                  case 3:
                    debugPrint("Chaud");
                    break;
                  default:
                    debugPrint("return null");
                    break;
                }
              },
              child: const Text("Custom"),
            ),
          ],
        ),
      ),
    );
  }
}
