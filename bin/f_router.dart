import 'dart:io';
import 'package:f_router/f_server.dart';

import 'package:path/path.dart' as path;

enum CompilerFlags {
  host(["-h", "--host"]),
  port(["-p", "--port"]),
  directory(["-d", "--directory"]),
  help(["--help"]),
  none([]);

  final List<String> flags;
  const CompilerFlags(this.flags);
  static CompilerFlags fromString(String arg) => switch (arg) {
        "-h" || "--host" => CompilerFlags.host,
        "-p" || "--port" => CompilerFlags.port,
        "-d" || "--directory" => CompilerFlags.directory,
        "--help" => CompilerFlags.help,
        _ => CompilerFlags.none
      };
}

({String host, int port, String dirPath}) _parseCompilerArguments(
    List<String> args,
    {required String defaultHost,
    required int defaultPort,
    required String defaultDirectoryPath}) {
  var state = CompilerFlags.none;
  String? host, dirPath;
  int? port;
  if (args.length > 2) {
    for (var arg in args) {
      if (state != CompilerFlags.none) {
        switch (state) {
          case CompilerFlags.host:
            host = arg;
            break;
          case CompilerFlags.port:
            port = int.tryParse(arg);
          case CompilerFlags.directory:
            dirPath = arg;
          case CompilerFlags.help:
            print(
                "Usage: f_router [args]\n-h or --host sets the host/address,\n-p or --port sets the port,\n-d or --directory sets the directory for file-based routing, --help shows this");
            exit(0);
          case CompilerFlags.none:
        }
      }
      state = CompilerFlags.fromString(arg);
    }
  }

  return (
    host: host ?? defaultHost,
    port: port ?? defaultPort,
    dirPath: dirPath ?? defaultDirectoryPath
  );
}

// Default directory is pages
void main(List<String> args) async {
  final currentDirectoryPath = path.current;
  final cArgs = _parseCompilerArguments(args,
      defaultHost: "127.0.0.1",
      defaultPort: 8000,
      defaultDirectoryPath: "/pages");

  final fServer = FServer(args,
      poweredByHeader: "Your mom",
      directoryPath: path.join(currentDirectoryPath, cArgs.dirPath),
      host: cArgs.host,
      port: cArgs.port);
  await fServer.serve();

  // print(File("${directory.path}\\pages\\home\\index.html").readAsStringSync());
}
