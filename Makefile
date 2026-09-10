.PHONY: setup teardown status scenarios-only defense-only clean

setup:
	@bash setup.sh

teardown:
	@bash teardown.sh

status:
	@echo "=== Namespaces ==="
	@kubectl get ns | grep koad || true
	@echo ""
	@echo "=== Scenario Pods ==="
	@kubectl get pods -n koad 2>/dev/null || echo "Namespace koad not found"
	@echo ""
	@echo "=== Attacker Pods ==="
	@kubectl get pods -n koad-attack 2>/dev/null || echo "Namespace koad-attack not found"
	@echo ""
	@echo "=== Defense Stack ==="
	@kubectl get pods -n falco 2>/dev/null || echo "Falco not installed"
	@helm list -n kyverno 2>/dev/null || echo "Kyverno not installed"

scenarios-only:
	@for dir in scenarios/*/; do \
		echo "Deploying $$dir..."; \
		kubectl apply -f "$$dir" 2>/dev/null || true; \
	done

defense-only:
	@bash setup.sh --defense-only

clean:
	@bash teardown.sh
	@minikube delete
