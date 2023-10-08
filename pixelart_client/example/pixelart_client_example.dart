import 'dart:io';
import 'package:pixelart_client/pixelart_client.dart';
import 'package:pixelart_shared/pixelart_shared.dart';
import 'package:uuid/uuid.dart';

void main() async {
  // Initialize a UUID generator
  Uuid uuid = Uuid();

  // Create a new PixelArt object
  PixelArt art = PixelArt(
    id: uuid.v4(),
    name: uuid.v4(),
    description: uuid.v4(),
    width: 64,
    height: 64,
    editors: [],
    pixelMatrix: [[]],
  );

  // Initialize the repository
  final repository = HTTPPixelArtRepository(url: "localhost:8080/pixelart");
  var connected = false;
  for (int i = 0; i < 10; i++) {
    var response = await repository.list();
    if (response.isFailure && response.status == CRUDStatus.NetworkError) {
      print(
          "NetworkError connecting to server. Is the server up and running? Start with 'dart_frog dev'");
      await Future.delayed(Duration(seconds: 2));
    } else {
      connected = true;
      break;
    }
  }

  if (!connected) {
    print(
        "Unable to connect to server. Is the server up and running? Start with 'dart_frog dev'");
    print("Exiting. Try again.");
    exit(255);
  }

  // TODO: 20. Use the create/read/list/update/delete/changes methods of the repository to show how it is supposed to be used.
  // Participants
  final john = Participant(id: '1', name: 'John Doe');
  final jane = Participant(id: '2', name: 'Jane Smith');

  // Pixels
  final redPixel = Pixel(
    red: 255,
    green: 0,
    blue: 0,
    alpha: 1,
    placedBy: john,
  );

  final bluePixel = Pixel(
    red: 0,
    green: 0,
    blue: 255,
    alpha: 1,
    placedBy: jane,
  );

  final greenPixel = Pixel(
    red: 0,
    green: 255,
    blue: 0,
    alpha: 1,
    placedBy: john,
  );

  // Create a PixelArt
  art = PixelArt(
    id: 'art1',
    name: 'Flag Art',
    description: 'A simple flag art',
    width: 3,
    height: 2,
    editors: [john, jane],
    pixelMatrix: [
      [redPixel, redPixel, redPixel],
      [bluePixel, bluePixel, bluePixel],
    ],
  );
  await repository.create(art);

  print('Pixel Art Created:');
  print('Name: ${art.name}');
  print('Description: ${art.description}');
  print('Width x Height: ${art.width}x${art.height}');
  print('Editors: ${art.editors.map((e) => e.name).join(', ')}');
  print('Pixel Matrix:');
  for (var row in art.pixelMatrix) {
    for (var pixel in row) {
      print(
          '${pixel.placedBy.name} placed a pixel with RGB(${pixel.red},${pixel.green},${pixel.blue})');
    }
  }
  print('-----------------------------');

  // Update PixelArt using placePixel
  art = art.placePixel(1, 1, greenPixel);
  await repository.update(art.id, art);

  print('Pixel Art Updated:');
  print(
      'Pixel at (1,1) updated to green by ${art.pixelMatrix[1][1].placedBy.name}');
  print('-----------------------------');

  // Read PixelArt using placePixel
  await repository.read(art.id);
  print('Pixel Art Read:');
  print('Name: ${art.name}');
  print('Description: ${art.description}');
  print('Width x Height: ${art.width}x${art.height}');
  print('Editors: ${art.editors.map((e) => e.name).join(', ')}');
  print('Pixel Matrix:');
  for (var row in art.pixelMatrix) {
    for (var pixel in row) {
      print(
          '${pixel.placedBy.name} placed a pixel with RGB(${pixel.red},${pixel.green},${pixel.blue})');
    }
  }
  print('-----------------------------');

  // Listed PixelArt using placePixel
  art = PixelArt(
    id: 'art2',
    name: 'Flag Art 2',
    description: 'A new simple flag art',
    width: 3,
    height: 2,
    editors: [john, jane],
    pixelMatrix: [
      [bluePixel, redPixel, bluePixel],
      [redPixel, bluePixel, redPixel],
    ],
  );
  await repository.create(art);
  
  await repository.list();

  print('Pixel Art Listed');
  print('-----------------------------');

  // Deleted PixelArt using placePixel
  await repository.delete(art.id);
  print('Pixel Art Deleted');
  print('-----------------------------');

  // Exit the application
  print('Exiting application.');
  exit(0);
}
