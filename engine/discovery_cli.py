import argparse
import sys
import os
from discovery import DiscoveryEngine

def main():
    parser = argparse.ArgumentParser(description="Distroless Discovery CLI")
    parser.add_argument("--name", required=True, help="Name of the package to discover (e.g., openssl, php)")
    parser.add_argument("--version", help="Explicit version to use (overrides discovery)")
    parser.add_argument("--url", help="Explicit source URL to use (overrides discovery)")
    parser.add_argument("--save", action="store_true", help="Save the generated YAML to the stacks/ directory")
    
    args = parser.parse_args()
    
    print(f"🔍 Starting discovery for: {args.name}...")
    engine = DiscoveryEngine()
    
    yaml_content = engine.propose_yaml(args.name, args.version, args.url)
    
    print("\n--- Proposed YAML Configuration ---")
    print(yaml_content)
    print("------------------------------------\n")
    
    if args.save:
        stack_path = f"stacks/{args.name}.yaml"
        if os.path.exists(stack_path):
            confirm = input(f"⚠️  {stack_path} already exists. Overwrite? (y/N): ")
            if confirm.lower() != 'y':
                print("❌ Aborted.")
                return
        
        with open(stack_path, 'w') as f:
            f.write(yaml_content)
        print(f"✅ Saved to {stack_path}")

if __name__ == "__main__":
    main()
