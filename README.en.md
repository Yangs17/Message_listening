# Message Listening Introduction

This project is primarily designed for relaying various types of messages, facilitating remote control of server data transmission and reception from terminals.

**Current Features:**
*   Local sending and receiving of Telegram (TG) bot information.

**Future Extensions:**
*   MQTT
*   WhatsApp
*   Lark/Feishu

**Program File Description:**
<img width="622" height="199" alt="image" src="https://github.com/user-attachments/assets/65827077-9fc2-4f43-b51e-8ed609bb9fa9" />


---

## Installation Guide

1.  Deploy directly using Docker.
2.  The `v2ray-linux-64.zip` file is downloaded and installed locally because the download speed can be slow. This is used to parse Vmess links. If your network environment is good, you can modify the external `Dockerfile` to download it directly.
3.  An empty folder named `logs` must be placed in the root directory of the project.
<img width="511" height="274" alt="image" src="https://github.com/user-attachments/assets/19c9b0e3-03ce-46e2-9d72-276910e86097" />


---

## Usage Instructions

1.  First, register a Telegram bot. You can search online for instructions on how to do this.
2.  In the `tg_bot` directory, ensure the ports defined in the `Dockerfile` and `main.py` files are consistent.
3.  The V2Ray image's port needs to be exposed to facilitate data transmission and reception between containers.
4.  The logic for handling Telegram bot interactions is detailed in `main.py`. You can modify it according to your needs, such as integrating scripts or large language models.
    *   Example functionality included: Replying "Hello" with "Hi".
    *   Another example: Replying with subscription information.
5.  All configuration information should be set in the `.env` file, which requires manual editing.

**Future Expansion:**
*   HTTP / HTTPS / MQTT integration with the TG bot (`main.c` handles forwarding) to enable data transmission from any terminal to Telegram.

---

## Achieved Effects

*   Enable automated conversations with the bot on Telegram.
*   Trigger remote servers via the bot.
*   Allow the remote server to send content to Telegram at any time, achieving a conversational control interface.
<img width="389" height="395" alt="image" src="https://github.com/user-attachments/assets/6cc218de-f5e5-4325-8f4e-f94214a56af3" />

---

## Contributing

1.  Fork this repository.
2.  Create a new branch named `Feat_xxx`.
3.  Commit your code.
4.  Submit a Pull Request.
