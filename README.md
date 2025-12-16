# Local RAG Vector Search System

Local, privacy-first retrieval-augmented search. Upload PDFs/TXT/MD/DOCX, embed them locally, and ask questions with answers grounded in your documents. No cloud dependencies.

## Quick Start

Requirements: Python 3.9+, Node 18+, Ollama (for LLM answers).

```bash
# Backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m app.main   # http://localhost:8000

# Frontend (new terminal)
cd frontend
npm install
npm run dev          # http://localhost:5173

# Ollama (for answers)
ollama serve
ollama pull llama3.2   # or mistral
```

## Use It
1) Open http://localhost:5173
2) Upload a doc (PDF/TXT/MD/DOCX)
3) Select which files to search
4) Ask a question and view the answer + sources

Sample file: `sample_document.md` (kept for quick testing).

## Architecture (brief)
- Frontend: React + Vite + Tailwind + Axios
- Backend: FastAPI + sentence-transformers + FAISS + Ollama
- Flow: Upload → extract text → chunk (500 size / 100 overlap) → embed → store in FAISS → query embeds → retrieve chunks → build prompt → LLM answer

## Key Choices
- Embeddings: `all-MiniLM-L6-v2` (fast, local, 384 dims)
- Vector store: FAISS IndexFlatL2 (simple, exact search, persistent)
- Chunking: ~500 tokens with ~100 overlap to keep context across boundaries
- LLM: Local via Ollama (no API keys; works offline; swap models easily)

## Troubleshooting
- Ports busy: `lsof -ti:8000 | xargs kill -9`, same for 5173/11434
- TypeScript squiggles: ensure `npm install`, then reload VS Code window
- Ollama not responding: `ollama serve`; list models with `ollama list`
- No LLM? Retrieval still works; answers will be context-only if LLM is down

## Repository Layout
- `backend/` FastAPI app, RAG pipeline, embeddings, FAISS store
- `frontend/` React UI
- `data/uploads` uploaded files, `data/vectordb` FAISS index
- `sample_document.md` demo content

## Notes
- To change models: adjust `LocalEmbedder` model name and/or Ollama model in `rag_pipeline.py`.
- To reset deps: remove `backend/venv` or `frontend/node_modules` and reinstall.

### 5. Chunking Strategies
- Text segmentation for retrieval
- Trade-offs: granularity vs context
- Overlap for boundary preservation

## Performance Considerations

### Embedding Speed
- ~400 sentences/sec on Apple M1
- Batch processing for multiple chunks
- Model loaded once at startup

### Search Speed
- O(n) for flat index (exact search)
- <100ms for 10K vectors
- Could use IVF for >100K vectors

### LLM Latency
- Depends on model size and hardware
- Typical: 2-10 seconds for response
- Faster models: Mistral, Phi-3
- Slower models: LLaMA 70B

### Storage
- FAISS index: ~4KB per vector (384 dims)
- 1,000 chunks ≈ 4MB index
- 10,000 chunks ≈ 40MB index

## Evaluation Approach

### Retrieval Quality
- **Recall@k**: What % of relevant chunks are in top-k?
- **MRR**: Mean Reciprocal Rank of first relevant chunk
- **NDCG**: Normalized Discounted Cumulative Gain

### Answer Quality
- **Faithfulness**: Answer grounded in context?
- **Relevance**: Answer addresses the question?
- **Completeness**: All important info included?

### Example Evaluation
Create test set of (question, expected_chunks) pairs:
```python
test_cases = [
    {
        "question": "What is the main conclusion?",
        "expected_chunks": [42, 43, 44],
        "document": "paper.pdf"
    }
]
```

Measure how often expected chunks appear in top-5.

## Credits

**ML Final Project 2024**

Built with:
- [FastAPI](https://fastapi.tiangolo.com/)
- [sentence-transformers](https://www.sbert.net/)
- [FAISS](https://github.com/facebookresearch/faiss)
- [Ollama](https://ollama.ai/)
- [React](https://react.dev/)
- [Vite](https://vitejs.dev/)

## License

MIT License - Educational project

## Troubleshooting

### Backend won't start
- Ensure Python 3.9+ is installed
- Check virtual environment is activated
- Verify all dependencies installed: `pip list`

### Embedding model download fails
- Check internet connection
- Models downloaded to `~/.cache/torch/sentence_transformers/`
- Try manually: `from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')`

### LLM not responding
- Ensure Ollama is running: `ollama serve`
- Check model is installed: `ollama list`
- Pull model: `ollama pull llama3.2`
- Verify endpoint: `curl http://localhost:11434/api/generate`

### Frontend won't connect to backend
- Check backend is running on port 8000
- Check CORS settings in `backend/app/main.py`
- Verify API URL in `frontend/src/api/client.ts`

### File upload fails
- Check file format is supported
- Verify file isn't corrupted
- Check `data/uploads/` directory exists and is writable

### No search results
- Ensure files are indexed (check `GET /api/files`)
- Verify files are selected in UI
- Try more specific questions
- Check embeddings were created successfully
