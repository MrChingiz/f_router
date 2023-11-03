import 'dart:io';
import 'dart:async';
import 'package:f_router/f_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
// import 'package:path/path.dart' as path;

class FServer {
  final List<String> args;
  // final Directory directory;
  final String poweredByHeader;
  final SecurityContext? securityContext;
  final ({String dirPath, String host, int port}) _hostPortDirPath;
  const FServer(this.args,
      {required String directoryPath,
      required String host,
      required int port,
      this.poweredByHeader = 'Dart with package:shelf',
      this.securityContext})
      : _hostPortDirPath = (dirPath: directoryPath, host: host, port: port);

  Directory get _dir => Directory(_hostPortDirPath.dirPath);

  Router get router => FRouter(_dir).handler;

  // ({String dirPath, String host, int port}) get _hostPortDirPath =>
  //     _parseCompilerArguments(args,
  //         defaultHost: "127.0.0.1",
  //         defaultPort: 8000,
  //         defaultDirectoryPath: directory.path);
  String get host => _hostPortDirPath.host;
  int get port => _hostPortDirPath.port;

  FutureOr<Response> Function(Request) get cascadeHandler =>
      Cascade().add(router.call).handler;
  Handler get pipe => Pipeline()
      .addMiddleware(logRequests(
        logger: (message, isError) =>
            print("${isError ? 'Error: ' : ''}$message"),
      ))
      .addHandler(cascadeHandler);

  Future<HttpServer> serve() => shelf_io
          .serve(pipe, host, port,
              poweredByHeader: poweredByHeader,
              securityContext: securityContext)
          .then((server) {
        print("Serving at ${server.address.host}:${server.port}");
        return server;
      });
}
