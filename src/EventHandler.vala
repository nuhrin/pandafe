using SDL;

public interface EventHandler : Object
{
	protected signal void quit_event_loop();
	protected void process_events() {
		drain_events();
		bool event_loop_done = false;		
		@interface.quit_all.connect(() => event_loop_done = true);
		@interface.pandora_keyup_event.connect(() => {
			if (handle_pandora_keyup_event() == false)
				event_loop_done = true;
		});
		quit_event_loop.connect(() => event_loop_done = true);
		while(event_loop_done == false) {
			do_event_loop();
			@interface.execute_idle_loop_work();
		}
		drain_events();
	}
	
	void do_event_loop() {
		Event event;
		while(Event.poll(out event) == 1) {
			switch(event.type) {
				case EventType.QUIT:
					@interface.quit_all();
					break;
				case EventType.KEYDOWN:
					if (event.key.keysym.mod == KeyModifier.CAPS)
						event.key.keysym.mod = KeyModifier.NONE; // CAPSLOCK causes trouble with selection
					this.on_keydown_event(event.key);
					break;
				case EventType.KEYUP:
					if (event.key.keysym.scancode == 147) { // pandora key
						if (MainClass.was_run_as_gui == true)
							@interface.pandora_keyup_event();
						break;
					}
					this.on_keyup_event(event.key);
					break;
				default:
					break;
			}
		}
	}
	
	protected virtual bool handle_pandora_keyup_event() { return false; }
	
	protected void drain_events() {
		int current_delay;
		int current_interval;
		SDL.get_key_repeat(out current_delay, out current_interval);
		
		if (current_delay > 0)
			SDL.enable_key_repeat(0);
		
		Event event;
        while(Event.poll(out event) == 1);
        
        if (current_delay > 0)
			SDL.enable_key_repeat(current_delay, current_interval);
	}
	
	protected abstract void on_keydown_event(KeyboardEvent event);
	protected virtual void on_keyup_event(KeyboardEvent event) { }
}
