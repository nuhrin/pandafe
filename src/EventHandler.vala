using Gee;
using SDL;

public interface EventHandler : Object
{
	protected signal void quit_event_loop();
	protected void process_events() {
		drain_events();
		
		bool event_loop_done = false;
		
		// setup handlers
		var handlers = new ArrayList<ulong>();		
		handlers.add(@interface.quit_all.connect(() => event_loop_done = true));
		handlers.add(@interface.pandora_keyup_event.connect(() => {
			if (@interface.pandora_keyup_event_handled == true)
				return;
			handle_pandora_keyup_event();
		}));
		ulong quit_event_loop_handler = quit_event_loop.connect(() => event_loop_done = true);
		
		// run event loop
		while(event_loop_done == false) {
			do_event_loop();
			@interface.execute_idle_loop_work();
		}
		drain_events();
		
		// disconnect handlers
		foreach(var handler in handlers)
			@interface.disconnect(handler);
		this.disconnect(quit_event_loop_handler);
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
	protected virtual void handle_pandora_keyup_event() { }	
}
