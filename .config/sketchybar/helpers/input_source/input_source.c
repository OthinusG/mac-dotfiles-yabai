#include <Carbon/Carbon.h>
#include <errno.h>
#include <pthread.h>
#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/event.h>
#include <sys/wait.h>
#include <unistd.h>

static const char *bar_path = "sketchybar";
extern char **environ;

static void trigger_update(void) {
  TISInputSourceRef source = TISCopyCurrentKeyboardInputSource();
  if (!source) return;

  CFStringRef identifier = TISGetInputSourceProperty(
    source, kTISPropertyInputSourceID);
  CFArrayRef languages = TISGetInputSourceProperty(
    source, kTISPropertyInputSourceLanguages);
  CFStringRef language = languages && CFArrayGetCount(languages) > 0
    ? CFArrayGetValueAtIndex(languages, 0) : NULL;

  char identifier_buffer[512] = "unknown";
  char language_buffer[64] = "unknown";
  if (identifier)
    CFStringGetCString(identifier, identifier_buffer,
                       sizeof(identifier_buffer), kCFStringEncodingUTF8);
  if (language)
    CFStringGetCString(language, language_buffer,
                       sizeof(language_buffer), kCFStringEncodingUTF8);

  char info_argument[sizeof(identifier_buffer) + 6];
  char language_argument[sizeof(language_buffer) + 10];
  snprintf(info_argument, sizeof(info_argument), "INFO=%s", identifier_buffer);
  snprintf(language_argument, sizeof(language_argument),
           "LANGUAGE=%s", language_buffer);

  char *arguments[] = {
    (char *)bar_path, "--trigger", "input_source_changed",
    info_argument, language_argument, NULL
  };
  pid_t child;
  if (posix_spawn(&child, bar_path, NULL, NULL, arguments, environ) == 0)
    while (waitpid(child, NULL, 0) < 0 && errno == EINTR) {}

  CFRelease(source);
}

static void input_source_changed(CFNotificationCenterRef center,
                                 void *observer,
                                 CFStringRef name,
                                 const void *object,
                                 CFDictionaryRef user_info) {
  trigger_update();
}

static void *exit_with_parent(void *context) {
  int queue = kqueue();
  if (queue < 0) _exit(1);

  struct kevent event;
  EV_SET(&event, (uintptr_t)getppid(), EVFILT_PROC,
         EV_ADD | EV_ONESHOT, NOTE_EXIT, 0, NULL);
  kevent(queue, &event, 1, &event, 1, NULL);
  _exit(0);
}

int main(int argc, char **argv) {
  if (argc != 2) return 1;
  bar_path = argv[1];

  usleep(500000);
  trigger_update();

  pthread_t parent_watcher;
  if (pthread_create(&parent_watcher, NULL, exit_with_parent, NULL) != 0)
    return 1;
  pthread_detach(parent_watcher);

  CFNotificationCenterAddObserver(
    CFNotificationCenterGetDistributedCenter(), NULL, input_source_changed,
    kTISNotifySelectedKeyboardInputSourceChanged, NULL,
    CFNotificationSuspensionBehaviorDeliverImmediately);

  CFRunLoopRun();
  return 0;
}
