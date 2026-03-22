# LangGraph Workflow Design

## Comprehensive Guide to Building Stateful AI Agent Workflows

---

## Table of Contents
1. [Introduction to LangGraph](#introduction)
2. [Core Concepts](#core-concepts)
3. [Graph Architecture Patterns](#architecture-patterns)
4. [Building Workflows Step-by-Step](#building-workflows)
5. [Advanced Techniques](#advanced-techniques)
6. [Best Practices](#best-practices)
7. [Real-World Examples](#examples)

---

## Introduction to LangGraph {#introduction}

**LangGraph** is a framework for building stateful, multi-step applications with LLMs. It extends LangChain with graph-based workflow orchestration, enabling:

- **Stateful operations**: Maintain context across steps
- **Cyclic flows**: Support iterative and conditional logic
- **Human-in-the-loop**: Pause for approval or input
- **Persistence**: Save and resume workflows
- **Debugging**: Inspect and replay execution

### Why LangGraph?

| Traditional Chains | LangGraph Workflows |
|-------------------|---------------------|
| Linear execution | Cyclic, conditional flows |
| Limited state management | Robust state handling |
| Hard to debug | Built-in observability |
| No pause/resume | Full persistence support |

---

## Core Concepts {#core-concepts}

### 1. **State**

The shared data structure passed between nodes.

```python
from typing import TypedDict, Annotated
from operator import add

class AgentState(TypedDict):
    messages: Annotated[list, add]  # Append-only list
    user_input: str
    current_step: str
    iterations: int
    final_answer: str
```

**Key Features**:
- **Typed**: Use TypedDict for structure
- **Reducers**: Control how updates merge (add, replace, custom)
- **Annotated**: Specify merge behavior per field

### 2. **Nodes**

Functions that process state and return updates.

```python
def agent_reasoning(state: AgentState) -> AgentState:
    """Node that performs reasoning."""
    messages = state["messages"]
    response = llm.invoke(messages)
    
    return {
        "messages": [response],
        "current_step": "reasoning_complete"
    }
```

**Node Characteristics**:
- Takes state as input
- Returns partial state updates
- Should be pure functions when possible
- Can be sync or async

### 3. **Edges**

Connections between nodes defining flow.

```python
# Conditional edge
def should_continue(state: AgentState) -> str:
    """Decide next node based on state."""
    if state["iterations"] > 5:
        return "end"
    elif needs_tool(state):
        return "tools"
    else:
        return "agent"

# Add to graph
graph.add_conditional_edges(
    "agent",
    should_continue,
    {
        "tools": "tool_node",
        "agent": "agent_reasoning",
        "end": END
    }
)
```

### 4. **Graph**

The workflow container.

```python
from langgraph.graph import StateGraph, END

# Create graph
workflow = StateGraph(AgentState)

# Add nodes
workflow.add_node("agent", agent_reasoning)
workflow.add_node("tools", tool_execution)

# Add edges
workflow.add_edge("tools", "agent")
workflow.add_conditional_edges("agent", should_continue)

# Set entry point
workflow.set_entry_point("agent")

# Compile
app = workflow.compile()
```

---

## Graph Architecture Patterns {#architecture-patterns}

### Pattern 1: **Linear Chain**

Simple sequential flow.

```
[Input] → [Step 1] → [Step 2] → [Step 3] → [Output]
```

```python
workflow = StateGraph(State)
workflow.add_node("step1", step1_func)
workflow.add_node("step2", step2_func)
workflow.add_node("step3", step3_func)

workflow.set_entry_point("step1")
workflow.add_edge("step1", "step2")
workflow.add_edge("step2", "step3")
workflow.add_edge("step3", END)
```

**Use Cases**: Simple pipelines, data transformations

---

### Pattern 2: **Router Pattern**

Branch based on conditions.

```
                    ┌→ [Path A] → [End]
[Input] → [Router] ─┼→ [Path B] → [End]
                    └→ [Path C] → [End]
```

```python
def route_query(state: State) -> str:
    query_type = classify_query(state["input"])
    return query_type  # "search", "calculate", or "chat"

workflow.add_conditional_edges(
    "router",
    route_query,
    {
        "search": "search_node",
        "calculate": "calc_node",
        "chat": "chat_node"
    }
)
```

**Use Cases**: Query classification, intent routing

---

### Pattern 3: **ReAct (Reasoning + Acting) Loop**

Iterative reasoning with tool use.

```
[Agent] ⇄ [Tools]
   ↓
[Output]
```

```python
class ReActState(TypedDict):
    messages: Annotated[list, add]
    iterations: int

def agent_node(state: ReActState):
    messages = state["messages"]
    response = agent.invoke(messages)
    return {"messages": [response]}

def tool_node(state: ReActState):
    messages = state["messages"]
    tool_calls = extract_tool_calls(messages[-1])
    results = execute_tools(tool_calls)
    return {"messages": results}

def should_continue(state: ReActState) -> str:
    last_message = state["messages"][-1]
    if has_tool_calls(last_message):
        return "tools"
    return "end"

workflow = StateGraph(ReActState)
workflow.add_node("agent", agent_node)
workflow.add_node("tools", tool_node)
workflow.set_entry_point("agent")
workflow.add_conditional_edges("agent", should_continue)
workflow.add_edge("tools", "agent")
```

**Use Cases**: Multi-step problem solving, research agents

---

### Pattern 4: **Human-in-the-Loop**

Pause for human approval.

```
[Agent] → [Review] → [Human Input] → [Continue/Revise]
```

```python
from langgraph.checkpoint.sqlite import SqliteSaver

def requires_approval(state: State) -> bool:
    return state.get("needs_approval", False)

workflow.add_conditional_edges(
    "agent",
    requires_approval,
    {
        True: "human_review",
        False: END
    }
)

# Compile with checkpointer
memory = SqliteSaver.from_conn_string(":memory:")
app = workflow.compile(checkpointer=memory, interrupt_before=["human_review"])

# Usage
config = {"configurable": {"thread_id": "1"}}
for event in app.stream(inputs, config):
    print(event)
    
# Resume after human input
app.invoke(None, config)  # Continues from interrupt
```

**Use Cases**: Content moderation, approval workflows, sensitive operations

---

### Pattern 5: **Map-Reduce**

Parallel processing with aggregation.

```
           ┌→ [Process A] ─┐
[Split] ───┼→ [Process B] ─┼→ [Reduce] → [Output]
           └→ [Process C] ─┘
```

```python
def split_node(state: State):
    items = state["items"]
    return {"batches": chunk_items(items, size=10)}

def map_node(state: State):
    # Processes one batch
    batch = state["current_batch"]
    results = [process_item(item) for item in batch]
    return {"results": results}

def reduce_node(state: State):
    all_results = state["results"]
    final = aggregate(all_results)
    return {"final_output": final}
```

**Use Cases**: Batch processing, parallel analysis, data aggregation

---

### Pattern 6: **Hierarchical Planning**

Plan then execute.

```
[Planner] → [Plan Review] → [Executor] → [Validator]
                ↑                            ↓
                └────────[Revise]────────────┘
```

```python
class PlanExecuteState(TypedDict):
    input: str
    plan: list[str]
    past_steps: Annotated[list, add]
    current_step: str
    result: str

def plan_step(state: PlanExecuteState):
    plan = planner.invoke(state["input"])
    return {"plan": plan}

def execute_step(state: PlanExecuteState):
    current = state["plan"][len(state["past_steps"])]
    result = executor.invoke(current)
    return {
        "past_steps": [current],
        "current_step": result
    }

def replan_needed(state: PlanExecuteState) -> str:
    if len(state["past_steps"]) >= len(state["plan"]):
        return "end"
    elif needs_replan(state):
        return "planner"
    return "executor"
```

**Use Cases**: Complex task automation, project planning

---

## Building Workflows Step-by-Step {#building-workflows}

### Complete Example: Customer Support Agent

```python
from typing import TypedDict, Annotated, Literal
from operator import add
from langgraph.graph import StateGraph, END
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, AIMessage

# 1. Define State
class SupportState(TypedDict):
    messages: Annotated[list, add]
    customer_id: str
    issue_type: str
    priority: str
    resolution: str
    needs_escalation: bool

# 2. Initialize Tools & LLM
llm = ChatOpenAI(model="gpt-4", temperature=0)

def get_customer_info(customer_id: str) -> dict:
    """Simulate customer lookup."""
    return {"name": "John Doe", "tier": "premium", "history": [...]}

def create_ticket(issue: str, priority: str) -> str:
    """Create support ticket."""
    return f"TICKET-{hash(issue)}"

# 3. Define Nodes
def classify_issue(state: SupportState) -> SupportState:
    """Classify the customer issue."""
    messages = state["messages"]
    
    prompt = f"""Classify this support issue into one of:
    - technical, billing, account, general
    
    Issue: {messages[-1].content}
    Reply with just the category."""
    
    response = llm.invoke(messages + [HumanMessage(content=prompt)])
    issue_type = response.content.strip().lower()
    
    # Set priority based on customer tier
    customer = get_customer_info(state["customer_id"])
    priority = "high" if customer["tier"] == "premium" else "normal"
    
    return {
        "issue_type": issue_type,
        "priority": priority,
        "messages": [response]
    }

def handle_technical(state: SupportState) -> SupportState:
    """Handle technical issues."""
    issue = state["messages"][0].content
    
    # Attempt automated resolution
    solution = llm.invoke([
        HumanMessage(content=f"Provide a solution for: {issue}")
    ])
    
    return {
        "resolution": solution.content,
        "messages": [solution]
    }

def handle_billing(state: SupportState) -> SupportState:
    """Handle billing issues."""
    # Billing requires human review
    return {
        "needs_escalation": True,
        "messages": [AIMessage(content="Escalating to billing team...")]
    }

def escalate(state: SupportState) -> SupportState:
    """Escalate to human agent."""
    ticket_id = create_ticket(
        state["messages"][0].content,
        state["priority"]
    )
    
    return {
        "resolution": f"Escalated - Ticket {ticket_id}",
        "messages": [AIMessage(content=f"Created ticket {ticket_id}")]
    }

# 4. Define Routing Logic
def route_by_type(state: SupportState) -> str:
    """Route based on issue type."""
    issue_type = state["issue_type"]
    
    routing = {
        "technical": "technical_handler",
        "billing": "billing_handler",
        "account": "escalate",
        "general": "technical_handler"
    }
    
    return routing.get(issue_type, "escalate")

def check_escalation(state: SupportState) -> Literal["escalate", "end"]:
    """Check if escalation needed."""
    if state.get("needs_escalation", False):
        return "escalate"
    return "end"

# 5. Build the Graph
workflow = StateGraph(SupportState)

# Add nodes
workflow.add_node("classifier", classify_issue)
workflow.add_node("technical_handler", handle_technical)
workflow.add_node("billing_handler", handle_billing)
workflow.add_node("escalate", escalate)

# Add edges
workflow.set_entry_point("classifier")

workflow.add_conditional_edges(
    "classifier",
    route_by_type
)

workflow.add_conditional_edges(
    "technical_handler",
    check_escalation
)

workflow.add_conditional_edges(
    "billing_handler",
    check_escalation
)

workflow.add_edge("escalate", END)

# 6. Compile
support_app = workflow.compile()

# 7. Visualize (optional)
try:
    from IPython.display import Image, display
    display(Image(support_app.get_graph().draw_mermaid_png()))
except:
    print("Graph visualization not available")

# 8. Use the Workflow
def handle_support_request(customer_id: str, issue: str):
    """Process a support request."""
    initial_state = {
        "messages": [HumanMessage(content=issue)],
        "customer_id": customer_id,
        "issue_type": "",
        "priority": "",
        "resolution": "",
        "needs_escalation": False
    }
    
    result = support_app.invoke(initial_state)
    
    return {
        "issue_type": result["issue_type"],
        "priority": result["priority"],
        "resolution": result["resolution"]
    }

# Test
result = handle_support_request(
    customer_id="CUST-123",
    issue="My login isn't working after password reset"
)
print(result)
```

---

## Advanced Techniques {#advanced-techniques}

### 1. **Persistence & Checkpointing**

Save workflow state for recovery and resume.

```python
from langgraph.checkpoint.sqlite import SqliteSaver

# Create persistent storage
memory = SqliteSaver.from_conn_string("checkpoints.db")

# Compile with checkpointing
app = workflow.compile(checkpointer=memory)

# Use with thread management
config = {"configurable": {"thread_id": "user-123"}}

# First run
for event in app.stream(initial_input, config):
    print(event)

# Resume later with same thread_id
app.invoke(new_input, config)  # Continues from saved state
```

### 2. **Streaming Updates**

Real-time progress tracking.

```python
# Stream node outputs
for output in app.stream(inputs):
    node_name = list(output.keys())[0]
    node_output = output[node_name]
    print(f"{node_name}: {node_output}")

# Stream with mode
for chunk in app.stream(inputs, stream_mode="values"):
    print(chunk)  # Full state after each node
```

### 3. **Subgraphs**

Compose workflows from smaller graphs.

```python
# Create subgraph
sub_workflow = StateGraph(SubState)
sub_workflow.add_node("sub1", func1)
sub_workflow.add_node("sub2", func2)
sub_compiled = sub_workflow.compile()

# Use as node in parent graph
def call_subgraph(state: ParentState):
    sub_input = transform_to_sub_state(state)
    result = sub_compiled.invoke(sub_input)
    return transform_to_parent_state(result)

main_workflow.add_node("subprocess", call_subgraph)
```

### 4. **Dynamic Nodes**

Add nodes at runtime.

```python
def dynamic_router(state: State) -> str:
    # Determine which specialized handler to use
    handler_type = state["handler_needed"]
    return f"handler_{handler_type}"

# Register multiple handlers
for handler_name in ["a", "b", "c"]:
    workflow.add_node(f"handler_{handler_name}", create_handler(handler_name))

workflow.add_conditional_edges("router", dynamic_router)
```

### 5. **Parallel Execution**

Run multiple nodes concurrently.

```python
from langgraph.graph import END

# Nodes run in parallel
workflow.add_node("parallel_1", func1)
workflow.add_node("parallel_2", func2)
workflow.add_node("parallel_3", func3)
workflow.add_node("merge", merge_results)

# All connect to same source
workflow.add_edge("start", "parallel_1")
workflow.add_edge("start", "parallel_2")
workflow.add_edge("start", "parallel_3")

# All feed into merge
workflow.add_edge("parallel_1", "merge")
workflow.add_edge("parallel_2", "merge")
workflow.add_edge("parallel_3", "merge")
```

### 6. **Custom Reducers**

Control state merging behavior.

```python
def merge_lists_uniquely(existing: list, new: list) -> list:
    """Custom reducer for unique list merging."""
    return list(set(existing + new))

class CustomState(TypedDict):
    tags: Annotated[list, merge_lists_uniquely]
    count: Annotated[int, lambda a, b: a + b]  # Sum
    latest: str  # Replace (default)
```

---

## Best Practices {#best-practices}

### ✅ State Design

```python
# GOOD: Clear, typed state
class WellDesignedState(TypedDict):
    user_input: str
    processed_data: dict
    results: Annotated[list, add]
    step_count: int

# AVOID: Unclear, untyped state
class PoorState(TypedDict):
    data: Any  # Too vague
    stuff: dict  # Unclear purpose
```

### ✅ Node Design

```python
# GOOD: Single responsibility, clear purpose
def validate_input(state: State) -> State:
    """Validate and sanitize user input."""
    cleaned = sanitize(state["user_input"])
    is_valid = validate(cleaned)
    return {"user_input": cleaned, "is_valid": is_valid}

# AVOID: Multiple responsibilities
def do_everything(state: State) -> State:
    # Validates, processes, stores, and returns
    # Too much in one node
    ...
```

### ✅ Error Handling

```python
def robust_node(state: State) -> State:
    """Node with proper error handling."""
    try:
        result = risky_operation(state["data"])
        return {"result": result, "error": None}
    except SpecificError as e:
        logger.error(f"Operation failed: {e}")
        return {
            "error": str(e),
            "needs_retry": True
        }
    except Exception as e:
        logger.exception("Unexpected error")
        return {
            "error": "system_error",
            "needs_escalation": True
        }
```

### ✅ Testing

```python
import pytest

def test_routing_logic():
    """Test conditional edge routing."""
    state = {"issue_type": "technical"}
    assert route_by_type(state) == "technical_handler"
    
    state = {"issue_type": "billing"}
    assert route_by_type(state) == "billing_handler"

def test_workflow_end_to_end():
    """Test complete workflow."""
    result = app.invoke({"input": "test query"})
    assert "result" in result
    assert result["step_count"] > 0
```

### ✅ Observability

```python
import logging

def instrumented_node(state: State) -> State:
    """Node with logging and metrics."""
    logger.info(f"Entering node with state: {state.keys()}")
    
    start_time = time.time()
    result = process(state)
    duration = time.time() - start_time
    
    logger.info(f"Node completed in {duration:.2f}s")
    metrics.record("node_duration", duration)
    
    return result
```

### ✅ Documentation

```python
def well_documented_node(state: AgentState) -> AgentState:
    """
    Process user query and generate response.
    
    Args:
        state: Current workflow state containing:
            - messages: Conversation history
            - user_input: Current user query
            
    Returns:
        State update with:
            - messages: Appended AI response
            - processing_time: Time taken in seconds
            
    Raises:
        ValueError: If user_input is empty
    """
    ...
```

---

## Real-World Examples {#examples}

### Example 1: Research Assistant

```python
class ResearchState(TypedDict):
    query: str
    search_results: Annotated[list, add]
    summaries: Annotated[list, add]
    final_report: str
    sources: list

def search_web(state: ResearchState):
    results = web_search(state["query"], num_results=5)
    return {"search_results": results}

def summarize_results(state: ResearchState):
    summaries = [
        llm.invoke(f"Summarize: {result}")
        for result in state["search_results"]
    ]
    return {"summaries": summaries}

def generate_report(state: ResearchState):
    report = llm.invoke(
        f"Create comprehensive report from: {state['summaries']}"
    )
    return {"final_report": report}

workflow = StateGraph(ResearchState)
workflow.add_node("search", search_web)
workflow.add_node("summarize", summarize_results)
workflow.add_node("report", generate_report)
workflow.set_entry_point("search")
workflow.add_edge("search", "summarize")
workflow.add_edge("summarize", "report")
workflow.add_edge("report", END)

research_app = workflow.compile()
```

### Example 2: Code Review Agent

```python
class CodeReviewState(TypedDict):
    code: str
    language: str
    issues: Annotated[list, add]
    suggestions: Annotated[list, add]
    security_check: dict
    final_score: int

def detect_language(state):
    lang = language_detector(state["code"])
    return {"language": lang}

def find_bugs(state):
    bugs = static_analyzer(state["code"], state["language"])
    return {"issues": bugs}

def security_scan(state):
    vulns = security_scanner(state["code"])
    return {"security_check": vulns}

def generate_suggestions(state):
    suggestions = llm.invoke(
        f"Improve this {state['language']} code: {state['code']}"
    )
    return {"suggestions": [suggestions]}

def calculate_score(state):
    score = 100 - (len(state["issues"]) * 10)
    return {"final_score": max(0, score)}

workflow = StateGraph(CodeReviewState)
workflow.add_node("detect", detect_language)
workflow.add_node("bugs", find_bugs)
workflow.add_node("security", security_scan)
workflow.add_node("suggest", generate_suggestions)
workflow.add_node("score", calculate_score)

workflow.set_entry_point("detect")
workflow.add_edge("detect", "bugs")
workflow.add_edge("detect", "security")  # Parallel
workflow.add_edge("bugs", "suggest")
workflow.add_edge("security", "suggest")
workflow.add_edge("suggest", "score")
workflow.add_edge("score", END)
```

---

## Summary Checklist

✅ **Understand core concepts**: State, Nodes, Edges, Graphs  
✅ **Know common patterns**: ReAct, Router, Human-in-loop, Map-Reduce  
✅ **Design clear state structures** with proper typing  
✅ **Create focused nodes** with single responsibilities  
✅ **Implement robust routing logic** with conditional edges  
✅ **Add persistence** for long-running workflows  
✅ **Include error handling** and recovery mechanisms  
✅ **Test workflows** thoroughly with unit and integration tests  
✅ **Monitor and observe** execution in production  
✅ **Document workflows** for maintainability  

---

## Additional Resources

- **Official Docs**: [langchain-ai/langgraph](https://github.com/langchain-ai/langgraph)
- **Examples**: LangGraph examples repository
- **Community**: LangChain Discord #langgraph channel
- **Tutorials**: LangChain YouTube channel

---

**Ready to build complex AI workflows with LangGraph!** 🚀