# Gomoku

## Description

Gomoku is an **artificial intelligence** project: a Gomoku game on a 19×19 Go board with an AI capable of beating human players.

Two players take turns placing stones, and aligning five or more wins. This version adds **captures** (flanking a pair of the opponent's stones removes them, and capturing ten stones also wins), **endgame captures** (a five-in-a-row only wins if the opponent cannot break it by capturing) and forbids **double-threes**.

The AI is built on a **Minimax** search driven by a custom heuristic, reaching at least ten plies deep while answering in under half a second on average. The game includes a player-vs-AI mode, a hotseat player-vs-player mode with move suggestions, and a graphical interface that shows the AI's thinking time.
