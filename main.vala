using YamlDB.Events;

public class MainClass: Object {
	public static int main (string[] args) {
		string yaml = """!system
Name: Nintendo
PrimaryEmu: fceu
Emulators:
- fceu
- mednafen""";

		//EventReader reader = new EventReader.from_string(yaml);
		EventReader reader = new EventReader(stdin);

		//FileStream output = FileStream.open("test.yaml", "w");
		EventEmitter emitter = new EventEmitter(stdout);


		int count=0;
		while(reader.move_next()) {
			stdout.printf("%d: %s\n", count, reader.Current.to_string());
			emitter.emit(reader.Current);
			count++;
		}



//		Event event = reader.get<StreamStart>();
//		//event = reader.get<DocumentStart>();
//		reader.skip();
//		event = reader.get<StreamEnd>();
//		stdout.printf("%s\n", event.to_string());

		stdout.printf("done.\n");
		return 0;
	}
}