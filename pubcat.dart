import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

const branch = 'branch';

ArgResults argResults;

Directory directory = Directory.current;

class GitHelper {
  String command = "git";
  String repo = "https://github.com/dart-lang/pub";
  String pubpath = "";
  String repopath = directory.path;
  String branch = "main";
  Map<String, List<String>> suffixes = {};
  Map<String, String> tagmapping = {};

  GitHelper(this.repo, this.pubpath, {this.branch}) {
    repopath = repopath + "/" + repo.split("/").last;
  }

  List<dynamic> clone() {
    var runner = ["clone"];
    if (this.branch.length > 0) {
      runner += ["--single-branch", "-b", branch];
    }
    runner += [this.repo];

    var result =
        Process.runSync(this.command, runner, workingDirectory: directory.path);

    return [result.exitCode, result.stdout, result.stderr];
  }

  List<dynamic> refs() {
    var result = Process.runSync(this.command, ["show-ref", "--tag"],
        workingDirectory: this.repopath);

    dynamic hashtags = result.stdout.split("\n");

    for (int i = 0; i < hashtags.length; i++) {
      List commit_tag = hashtags[i].split(" ");
      if (commit_tag.length == 2) {
        this.tagmapping[commit_tag[1].toString()] = commit_tag[0].toString();
      }
    }

    return [result.exitCode, result.stdout, result.stderr];
  }

  String parse_package_version(String content) {
    var yaml = loadYaml(content);
    return yaml["version"];
  }

  void pubspec(bool verbose) {
    this.tagmapping.forEach((tag, commit_hash) {
      var content = Process.runSync(
          "git", ["show", this.tagmapping[tag] + ":pubspec.yaml"],
          workingDirectory: this.repopath + this.pubpath);

      if (content.exitCode == 0) {
        print(
            "\n\npubspec.yaml found for ${tag} \nPACKAGE VERSION FROM PUBSPEC: ${parse_package_version(content.stdout)}\n");
      } else {
        print("Couldn't find pubspec.yaml for ${tag}");
      }
      if (verbose) {
        print(content.stdout);
      }
    });
  }
}

void main(List<String> arguments) {
  exitCode = 0; // presume success
  final parser = ArgParser()
    ..addOption(branch, abbr: 'b', help: "Clone specific branch of the repo.")
    ..addFlag("clean",
        defaultsTo: false,
        negatable: false,
        abbr: "c",
        help: "Clean cloned repositories after use.")
    ..addFlag("verbose",
        defaultsTo: false,
        negatable: false,
        abbr: "v",
        help: "Print pubspec.yaml contents")
    ..addFlag("help",
        abbr: "h", negatable: false, defaultsTo: false, help: "pubcat help");

  argResults = parser.parse(arguments);

  if (argResults["help"]) {
    print("dart pubcat.dart <repo url> <pubspec path>");
    print(parser.usage);
    return;
  }

  final repo = argResults.rest[0];
  final path = argResults.rest.length > 1 ? argResults.rest[1] : "";

  pubcat(
    repo,
    path,
    branch: argResults["branch"] ?? "",
    clean: argResults["clean"],
  );
}

Future pubcat(String repo, String pubspec_path,
    {String branch: "", bool clean: false}) async {
  final helper = GitHelper(repo, pubspec_path, branch: branch);

  helper.clone();
  helper.refs();
  helper.pubspec(argResults["verbose"]);

  if (clean) {
    Directory(helper.repopath).delete(recursive: true);
  }
}
