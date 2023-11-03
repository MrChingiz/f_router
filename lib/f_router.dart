import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as path;

class Throws {
  final Type expectionType;
  const Throws(this.expectionType);
}

const mimeTypeByExtension = {
  "html": "text/html",
  "css": "text/css",
  "js": "application/javascript",
  "json": "application/json",
  "jpg": "image/jpeg",
  "jpeg": "image/jpeg",
  "png": "image/png",
  "gif": "image/gif",
  "pdf": "application/pdf",
  "txt": "text/plain",
  // Add more mappings as needed
};

class FRouter {
  final Directory directory;
  // final Router _router = Router();
  const FRouter(this.directory);

  FutureOr<Response> _handleGet(Request request, String webPath) {
    // print("Dirpath: ${directory.path}");
    // @Throws(FormatException)
    // final context =
    //     path.Context(style: path.Style.platform, current: directory.path);

    final filePath = path.join(directory.path, webPath);

    print("file path: $filePath");
    // @Throws(UnsupportedError)
    switch (FileSystemEntity.typeSync(filePath)) {
      case FileSystemEntityType.directory:
        // print("directory: $filePath");
        return _handleGet(request, "$webPath/index.html");
      case FileSystemEntityType.file:
        final extension = path.extension(webPath).substring(1);
        return Response.ok(File(filePath).openRead(),
            headers: mimeTypeByExtension.containsKey(extension)
                ? {"Content-Type": mimeTypeByExtension[extension]!}
                : {});
      default:
        // print("FileSystemEntityType:");
        return Response.notFound("Not found");
    }
  }

  Router get handler {
    final router = Router()..get("/<path>", _handleGet);
    // print("dir: ${Directory.current}");
    return router;
  }
}
