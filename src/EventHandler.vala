using SDL;

public interface EventHandler : Object
{
	protected signal void quit_event_loop();
	protected void process_events() {
		drain_events();
		bool event_loop_done = false;
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
					quit_event_loop();
					break;
				case EventType.KEYDOWN:
					this.on_keydown_event(event.key);
					break;
				case EventType.KEYUP:
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
}
