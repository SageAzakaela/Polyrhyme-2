import tkinter as tk
from tkinter import filedialog, messagebox
import librosa
import librosa.display
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image, ImageTk
import os

class SpectrogramGenerator:
    def __init__(self, root):
        self.root = root
        self.root.title("Spectrogram Generator")
        
        self.file_path = None
        
        self.load_button = tk.Button(root, text="Load Audio File", command=self.load_file)
        self.load_button.pack(pady=10)
        
        self.generate_button = tk.Button(root, text="Generate Spectrogram", command=self.generate_spectrogram, state=tk.DISABLED)
        self.generate_button.pack(pady=10)
        
        self.preview_label = tk.Label(root)
        self.preview_label.pack(pady=10)
    
    def load_file(self):
        self.file_path = filedialog.askopenfilename(filetypes=[("Audio files", "*.mp3;*.wav")])
        if self.file_path:
            self.generate_button.config(state=tk.NORMAL)
            self.preview_label.config(image='', text=f"Loaded: {os.path.basename(self.file_path)}")
    
    def generate_spectrogram(self):
        if not self.file_path:
            messagebox.showerror("Error", "Please load an audio file first.")
            return
        
        # Extract filename without extension and create output file name
        base_name = os.path.splitext(os.path.basename(self.file_path))[0]
        output_image = os.path.join(os.path.dirname(self.file_path), f"{base_name}.png")
        
        # Load the audio file
        y, sr = librosa.load(self.file_path, sr=None)
        
        # Create a Short-Time Fourier Transform (STFT)
        D = np.abs(librosa.stft(y))
        
        # Convert to Decibels
        DB = librosa.amplitude_to_db(D, ref=np.max)
        
        # Plot the spectrogram without axes, color bar, and text
        plt.figure(figsize=(10, 6))  # Adjust size if needed
        librosa.display.specshow(DB, sr=sr, x_axis=None, y_axis=None, cmap='magma')
        plt.axis('off')
        
        # Save the spectrogram image without any padding
        temp_image = "temp_spectrogram.png"
        plt.savefig(temp_image, bbox_inches='tight', pad_inches=0)
        plt.close()

        # Load the image and rotate it 90 degrees to be vertical
        img = Image.open(temp_image)
        vertical_img = img.rotate(270, expand=True)
        vertical_img.save(output_image)
        
        # Load and display the saved image as a preview
        img.thumbnail((300, 300))
        self.spectrogram_img = ImageTk.PhotoImage(img)
        self.preview_label.config(image=self.spectrogram_img, text=f"Saved as {output_image}")
        messagebox.showinfo("Success", f"Spectrogram saved as {output_image}")

if __name__ == "__main__":
    root = tk.Tk()
    app = SpectrogramGenerator(root)
    root.mainloop()
