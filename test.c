#include <string.h> // This is the header that's failing
#include <SDL3/SDL.h> // Also try an SDL header to check dependency includes

int main() {
    char* my_string = strdup("Hello, Emscripten!");
    // If you were trying to use SDL, you could uncomment this, but it's not essential for this test:
    // SDL_Init(SDL_INIT_VIDEO);
    // printf("%s\n", my_string);
    // SDL_Quit();
    return 0;
}
