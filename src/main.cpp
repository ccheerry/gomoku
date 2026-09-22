#include <imgui.h>
#include <raylib.h>
#include <rlImGui.h>

int main()
{
	SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_MSAA_4X_HINT | FLAG_VSYNC_HINT);
	InitWindow(1280, 720, "Gomoku");
	SetExitKey(KEY_NULL);
	rlImGuiSetup(true);
	while (!WindowShouldClose()) {
		BeginDrawing();
		ClearBackground(Color{17, 20, 24, 255});
		DrawText("Gomoku", 40, 40, 40, RAYWHITE);
		rlImGuiBegin();
		ImGui::Text("ImGui OK");
		rlImGuiEnd();
		EndDrawing();
	}
	rlImGuiShutdown();
	CloseWindow();
}
