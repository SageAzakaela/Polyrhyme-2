import tkinter as tk
from tkinter import filedialog, simpledialog
import json
import pygame
from PIL import Image, ImageTk

class ChartEditor:
    def __init__(self, root):
        self.root = root
        self.root.title("Chart Editor")

        self.grid_size = 20
        self.bpm = 120
        self.lanes = ["a", "s", "d", "f", "j", "k", "l", ";"]
        self.colors = ["red", "orange", "yellow", "green", "cyan", "blue", "purple", "magenta"]
        self.notes = []
        self.file_path = None
        self.audio_file_path = None
        self.spectrogram_image_path = None
        self.spectrogram_image = None
        self.playing = False
        self.playback_position = 0
        self.track_length = 195  # Default length, should be updated when the track is loaded

        # Initialize pygame mixer for audio playback
        pygame.mixer.init()

        self.canvas_frame = tk.Frame(self.root)
        self.canvas_frame.pack(fill=tk.BOTH, expand=True)

        self.canvas = tk.Canvas(self.canvas_frame, bg="white")
        self.canvas.grid(row=0, column=1, sticky="nsew")

        # Set up vertical scrollbar
        self.scroll_y = tk.Scrollbar(self.canvas_frame, orient=tk.VERTICAL, command=self.canvas.yview)
        self.scroll_y.grid(row=0, column=2, sticky="ns")

        # Set up horizontal scrollbar
        self.scroll_x = tk.Scrollbar(self.canvas_frame, orient=tk.HORIZONTAL, command=self.canvas.xview)
        self.scroll_x.grid(row=1, column=1, sticky="ew")

        self.canvas.config(yscrollcommand=self.scroll_y.set, xscrollcommand=self.scroll_x.set)

        # Configure the grid to expand correctly
        self.canvas_frame.grid_rowconfigure(0, weight=1)
        self.canvas_frame.grid_columnconfigure(1, weight=1)

        self.menu = tk.Menu(self.root)
        self.root.config(menu=self.menu)
        self.file_menu = tk.Menu(self.menu)
        self.menu.add_cascade(label="File", menu=self.file_menu)
        self.file_menu.add_command(label="Open Chart", command=self.open_file)
        self.file_menu.add_command(label="Save Chart", command=self.save_file)
        self.file_menu.add_command(label="Save Chart As", command=self.save_as_file)
        self.file_menu.add_command(label="Open Audio File", command=self.open_audio_file)
        self.file_menu.add_command(label="Load Spectrogram", command=self.load_spectrogram_image)

        self.controls_frame = tk.Frame(self.root)
        self.controls_frame.pack()

        self.play_button = tk.Button(self.controls_frame, text="Play", command=self.play_track)
        self.play_button.pack(side=tk.LEFT)

        self.pause_button = tk.Button(self.controls_frame, text="Pause", command=self.pause_track)
        self.pause_button.pack(side=tk.LEFT)

        self.stop_button = tk.Button(self.controls_frame, text="Stop", command=self.stop_track)
        self.stop_button.pack(side=tk.LEFT)

        self.selected_note = None
        self.playback_indicator = None

        self.canvas.bind("<Button-1>", self.select_note)
        self.canvas.bind("<B1-Motion>", self.drag_note)
        self.canvas.bind("<Double-Button-1>", self.add_note)
        self.canvas.bind("<Button-3>", self.delete_note)

    def open_file(self):
        self.file_path = filedialog.askopenfilename(filetypes=[("JSON files", "*.json")])
        if self.file_path:
            with open(self.file_path, "r") as file:
                self.notes = json.load(file)
            
            # Prompt the user to enter the correct BPM
            bpm_input = simpledialog.askinteger("Enter BPM", "Please enter the BPM for this chart:", initialvalue=self.bpm)
            if bpm_input:
                self.bpm = bpm_input

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

    def open_audio_file(self):
        self.audio_file_path = filedialog.askopenfilename(filetypes=[("Audio files", "*.mp3;*.wav")])
        if self.audio_file_path:
            print(f"Audio file loaded: {self.audio_file_path}")
            # Load the audio to check its length and set it
            pygame.mixer.music.load(self.audio_file_path)
            self.track_length = pygame.mixer.Sound(self.audio_file_path).get_length()

    def load_spectrogram_image(self):
        self.spectrogram_image_path = filedialog.askopenfilename(filetypes=[("Image files", "*.png;*.jpg")])
        if self.spectrogram_image_path:
            self.spectrogram_image = Image.open(self.spectrogram_image_path)
            self.display_chart()

    def display_chart(self):
        self.canvas.delete("all")
        self.draw_spectrogram()
        self.draw_grid()
        self.draw_time_ruler()
        for note in self.notes:
            self.create_note_visual(note)

        if self.playback_indicator is None:
            self.playback_indicator = self.canvas.create_line(0, 0, len(self.lanes) * self.grid_size, 0, fill="red", width=2)

        # Update scroll region dynamically based on track length
        self.update_scroll_region()

    def draw_spectrogram(self):
        if self.spectrogram_image:
            # Calculate the dimensions of the spectrogram to fit the grid
            total_width = len(self.lanes) * self.grid_size
            total_height = int(self.track_length * self.grid_size / (60 / self.bpm) * 4)

            # Resize the spectrogram to fit the canvas
            resized_spectrogram = self.spectrogram_image.resize((total_width, total_height), Image.LANCZOS)
            self.spectrogram_tk = ImageTk.PhotoImage(resized_spectrogram)

            # Draw the spectrogram image on the canvas, placed to the right of the time ruler
            self.canvas.create_image(0, 0, anchor="nw", image=self.spectrogram_tk)

    def draw_grid(self):
        num_lanes = len(self.lanes)
        total_beats = int(self.track_length / (60 / self.bpm))

        for i in range(total_beats * 4):
            y = i * self.grid_size
            self.canvas.create_line(0, y, num_lanes * self.grid_size, y, fill="lightgray")

        for j in range(num_lanes):
            x = j * self.grid_size
            self.canvas.create_line(x, 0, x, total_beats * 4 * self.grid_size, fill="lightgray")

    def draw_time_ruler(self):
        total_beats = int(self.track_length / (60 / self.bpm))

        for i in range(total_beats * 4):
            y = i * self.grid_size
            time_in_seconds = round(i * (60 / self.bpm / 4), 2)
            if i % 4 == 0:  # Major tick every beat
                self.canvas.create_line(len(self.lanes) * self.grid_size, y, (len(self.lanes) * self.grid_size) + 10, y, fill="black", width=2)
                self.canvas.create_text((len(self.lanes) * self.grid_size) + 20, y, anchor="w", text=f"{time_in_seconds:.1f}s")
            else:  # Minor tick every sixteenth note
                self.canvas.create_line(len(self.lanes) * self.grid_size, y, (len(self.lanes) * self.grid_size) + 5, y, fill="black", width=1)

    def update_scroll_region(self):
        num_lanes = len(self.lanes)
        total_height = int(self.track_length * self.grid_size / (60 / self.bpm) * 4)
        total_width = num_lanes * self.grid_size
        self.canvas.config(scrollregion=(0, 0, total_width + 50, total_height))  # Added margin for time ruler on the right

    def create_note_visual(self, note):
        lane_index = self.lanes.index(note["key"])
        time_position = round(note["time"] / (60 / self.bpm / 4)) * self.grid_size
        lane_position = lane_index * self.grid_size

        rect = self.canvas.create_rectangle(
            lane_position, time_position,
            lane_position + self.grid_size, time_position + self.grid_size,
            fill=self.colors[lane_index]
        )

        # Bind the rectangle to events
        self.canvas.tag_bind(rect, "<Button-1>", lambda event, n=note: self.select_note_from_click(event, n))
        self.canvas.tag_bind(rect, "<B1-Motion>", lambda event, n=note: self.drag_note(event, n))

        note["rect"] = rect  # Store the rectangle ID in the note

    def select_note_from_click(self, event, note):
        self.selected_note = note

    def select_note(self, event):
        self.selected_note = None
        # Adjust coordinates to account for scrolling
        adjusted_x = self.canvas.canvasx(event.x)
        adjusted_y = self.canvas.canvasy(event.y)
        for note in self.notes:
            x1, y1, x2, y2 = self.canvas.coords(note["rect"])
            if x1 <= adjusted_x <= x2 and y1 <= adjusted_y <= y2:
                self.selected_note = note
                break

    def drag_note(self, event, note):
        if self.selected_note == note:
            # Adjust coordinates to account for scrolling
            adjusted_x = self.canvas.canvasx(event.x)
            adjusted_y = self.canvas.canvasy(event.y)
            new_time = round(adjusted_y / self.grid_size) * (60 / self.bpm / 4)
            new_lane_index = int(adjusted_x / self.grid_size)

            if 0 <= new_lane_index < len(self.lanes):
                note["time"] = new_time
                note["key"] = self.lanes[new_lane_index]

                self.canvas.coords(
                    note["rect"],
                    new_lane_index * self.grid_size, int(new_time / (60 / self.bpm / 4)) * self.grid_size,
                    (new_lane_index + 1) * self.grid_size, int(new_time / (60 / self.bpm / 4)) * self.grid_size + self.grid_size
                )

                # Change the color to match the new lane
                self.canvas.itemconfig(note["rect"], fill=self.colors[new_lane_index])

    def add_note(self, event):
        # Adjust coordinates to account for scrolling
        adjusted_x = self.canvas.canvasx(event.x)
        adjusted_y = self.canvas.canvasy(event.y)
        new_time = round(adjusted_y / self.grid_size) * (60 / self.bpm / 4)
        new_lane_index = int(adjusted_x / self.grid_size)

        if 0 <= new_lane_index < len(self.lanes):
            new_note = {
                "time": new_time,
                "key": self.lanes[new_lane_index],
                "rect": None
            }
            self.notes.append(new_note)
            self.create_note_visual(new_note)

    def delete_note(self, event):
        if self.selected_note:
            self.canvas.delete(self.selected_note["rect"])
            self.notes.remove(self.selected_note)
            self.selected_note = None

    def play_track(self):
        if self.audio_file_path and not self.playing:
            pygame.mixer.music.load(self.audio_file_path)
            pygame.mixer.music.play(loops=0, start=self.playback_position)
            self.playing = True
            self.update_playback_indicator()

    def pause_track(self):
        if self.playing:
            pygame.mixer.music.pause()
            self.playing = False
            self.playback_position = pygame.mixer.music.get_pos() / 1000.0

    def stop_track(self):
        if self.playing:
            pygame.mixer.music.stop()
            self.playing = False
            self.playback_position = 0
            self.canvas.coords(self.playback_indicator, 0, 0, len(self.lanes) * self.grid_size, 0)

    def update_playback_indicator(self):
        if self.playing:
            # Get the current position of the playback in seconds
            current_pos = pygame.mixer.music.get_pos() / 1000.0
            
            # Calculate the y-coordinate of the playback indicator
            y = current_pos * self.grid_size / (60 / self.bpm / 4)
            
            # Update the position of the playback indicator line
            self.canvas.coords(self.playback_indicator, 0, y, len(self.lanes) * self.grid_size, y)
            
            # Scroll the canvas to keep the playback indicator in view
            canvas_height = int(self.canvas.cget('scrollregion').split()[3])
            self.canvas.yview_moveto(y / canvas_height)
            
            # Update every 50 milliseconds
            self.root.after(50, self.update_playback_indicator)


if __name__ == "__main__":
    root = tk.Tk()
    app = ChartEditor(root)
    root.mainloop()
