import tkinter as tk
from tkinter import filedialog, messagebox
import json

class ChartEditor:
    def __init__(self, root):
        self.root = root
        self.root.title("Chart Editor")

        self.grid_size = 20
        self.bpm = 120
        self.lanes = ["a", "s", "k", "l"]
        self.notes = []
        self.file_path = None

        self.canvas_frame = tk.Frame(self.root)
        self.canvas_frame.pack(fill=tk.BOTH, expand=True)

        self.canvas = tk.Canvas(self.canvas_frame, bg="white", scrollregion=(0, 0, 2000, 400))
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.scroll_x = tk.Scrollbar(self.canvas_frame, orient=tk.HORIZONTAL, command=self.canvas.xview)
        self.scroll_x.pack(side=tk.BOTTOM, fill=tk.X)
        self.scroll_y = tk.Scrollbar(self.canvas_frame, orient=tk.VERTICAL, command=self.canvas.yview)
        self.scroll_y.pack(side=tk.RIGHT, fill=tk.Y)

        self.canvas.config(xscrollcommand=self.scroll_x.set, yscrollcommand=self.scroll_y.set)

        self.canvas.bind("<Button-1>", self.select_note)
        self.canvas.bind("<B1-Motion>", self.move_note)

        self.menu = tk.Menu(self.root)
        self.root.config(menu=self.menu)
        self.file_menu = tk.Menu(self.menu)
        self.menu.add_cascade(label="File", menu=self.file_menu)
        self.file_menu.add_command(label="Open", command=self.open_file)
        self.file_menu.add_command(label="Save", command=self.save_file)
        self.file_menu.add_command(label="Save As", command=self.save_as_file)

        self.selected_note = None

    def open_file(self):
        self.file_path = filedialog.askopenfilename(filetypes=[("JSON files", "*.json")])
        if self.file_path:
            with open(self.file_path, "r") as file:
                self.notes = json.load(file)
            self.display_chart()

    def save_file(self):
        if not self.file_path:
            self.save_as_file()
        else:
            with open(self.file_path, "w") as file:
                json.dump(self.notes, file, indent=4)

    def save_as_file(self):
        self.file_path = filedialog.asksaveasfilename(defaultextension=".json", filetypes=[("JSON files", "*.json")])
        if self.file_path:
            self.save_file()

    def display_chart(self):
        self.canvas.delete("all")
        self.draw_grid()
        for note in self.notes:
            self.create_note_visual(note)

    def draw_grid(self):
        num_lanes = len(self.lanes)
        beat_duration = 60 / self.bpm
        sixteenth_duration = beat_duration / 4
        total_beats = int(200 / beat_duration)

        for i in range(total_beats * 4):
            x = i * self.grid_size
            self.canvas.create_line(x, 0, x, num_lanes * self.grid_size, fill="lightgray")

        for j in range(num_lanes):
            y = j * self.grid_size
            self.canvas.create_line(0, y, total_beats * 4 * self.grid_size, y, fill="lightgray")

    def create_note_visual(self, note):
        lane_index = self.lanes.index(note["key"])
        time_position = int(note["time"] / (60 / self.bpm / 4)) * self.grid_size
        lane_position = lane_index * self.grid_size

        rect = self.canvas.create_rectangle(
            time_position, lane_position,
            time_position + self.grid_size, lane_position + self.grid_size,
            fill="blue"
        )
        self.canvas.tag_bind(rect, "<Button-1>", lambda event, n=note: self.select_note_from_click(event, n))

        note["rect"] = rect

    def select_note_from_click(self, event, note):
        self.selected_note = note

    def select_note(self, event):
        self.selected_note = None
        for note in self.notes:
            x1, y1, x2, y2 = self.canvas.coords(note["rect"])
            if x1 <= event.x <= x2 and y1 <= event.y <= y2:
                self.selected_note = note
                break

    def move_note(self, event):
        if self.selected_note:
            new_time = event.x / self.grid_size * (60 / self.bpm / 4)
            new_lane_index = int(event.y / self.grid_size)

            if 0 <= new_lane_index < len(self.lanes):
                self.selected_note["time"] = new_time
                self.selected_note["key"] = self.lanes[new_lane_index]

                self.canvas.coords(
                    self.selected_note["rect"],
                    int(new_time / (60 / self.bpm / 4)) * self.grid_size, new_lane_index * self.grid_size,
                    int(new_time / (60 / self.bpm / 4)) * self.grid_size + self.grid_size, (new_lane_index + 1) * self.grid_size
                )

if __name__ == "__main__":
    root = tk.Tk()
    app = ChartEditor(root)
    root.mainloop()
