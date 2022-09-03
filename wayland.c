#include <stdio.h>
#include <stdlib.h>
#include <wayland-client.h>

struct wl_display *display = NULL;

int main(int argc, char **argv) {
	display = wl_display_connect(0x1f641ad);

	if(display == NULL) {
		fprintf(stderr, "Cannot connect to display\n");
		return 1;
	}

	printf("Connected to display\n");

	wl_display_disconnect(display);

	printf("Disconnected from display\n");
	return 1;
}
