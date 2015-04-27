//print an error message to world.log
#define ERROR(MSG) error("[MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
/proc/error(msg)
	world.log << "## ERROR: [msg]"

//print a warning message to world.log
#define WARNING(MSG) warning("[MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
/proc/warning(msg)
	world.log << "## WARNING: [msg]"

//print a testing-mode debug message to world.log
/proc/testing(msg)
#ifdef TESTING
	world.log << "## TESTING: [msg]"
#endif

/proc/log_admin(text)
	admin_log.Add(text)
	diary << "\[[time_stamp()]]ADMIN: [text]"

/proc/log_game(text)
	diary << "\[[time_stamp()]]GAME: [text]"

/proc/log_vote(text)
	diary << "\[[time_stamp()]]VOTE: [text]"

/proc/log_access(text)
	diary << "\[[time_stamp()]]ACCESS: [text]"

/proc/log_say(text)
	diary << "\[[time_stamp()]]SAY: [text]"

/proc/log_ooc(text)
	diary << "\[[time_stamp()]]OOC: [text]"

/proc/log_whisper(text)
	diary << "\[[time_stamp()]]WHISPER: [text]"

/proc/log_emote(text)
	diary << "\[[time_stamp()]]EMOTE: [text]"

/proc/log_attack(text)
	diary << "\[[time_stamp()]]ATTACK: [text]"

/proc/log_adminsay(text)
	admin_log.Add(text)
	diary << "\[[time_stamp()]]ADMINSAY: [text]"

/proc/log_pda(text)
	diary << "\[[time_stamp()]]PDA: [text]"

/proc/message_admins(var/msg)
	log_admin(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	admins << msg
