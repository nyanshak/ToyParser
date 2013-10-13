using namespace std;

struct i_pair {
        int state;
        string input;
    i_pair(int s = -1, string i = "") {
        state = s;
        input = i;
    }

    friend bool operator<(const i_pair& foo, const i_pair& foo1) {
        if (foo.state == foo1.state){
                return foo.input < foo1.input;
        }
        return foo.state < foo1.state;
    }

    friend bool operator>(const i_pair& foo, const i_pair& foo1) {
        if (foo.state == foo1.state){
            return foo.input > foo1.input;
        }
        return foo.state > foo1.state;
    }

};

struct Node {
	char* label;
	struct Node* parent;
	struct Node* child;
	struct Node* right_sibling;
} *node;

Node* createNode(char* label) {
	Node* temp;
	temp = (Node*)malloc(sizeof(Node));
	if (temp == NULL) {
		cout << "Out of memory error when trying to create node" << endl;
		exit(-1);
	}
	
	temp->label = (char*)malloc(strlen(label) + 1);
	strcpy(temp->label, label);
	if (temp->label == NULL) {
		cout << "Out of memory error when trying to create node" << endl;
		exit(-1);
	}
	temp->child = NULL;
	temp->right_sibling = NULL;

	return temp;
}

void deleteNode(Node* node) {
	if(node->child) {
		deleteNode(node->child);
	}

	if(node->right_sibling) {
		deleteNode(node->right_sibling);
	}
	free(node);
}

void addChildNode(Node* parent, Node* child) {
	if(parent->child) {
		Node* sibling = parent->child;
		Node* prev = parent->child;
		while(sibling) {
			prev = sibling;
			sibling = prev->right_sibling;
		}
		prev->right_sibling = child;
	} else {
		parent->child = child;
	}
	child->parent = parent;
}


string convertInt(int n) {
	stringstream ss;
	ss << n;
	return ss.str();
}

string convertToLowerCase(string str) {
	for (int i = 0; i < strlen(str.c_str()); i++){
		str[i] = tolower(str[i]);
	}
	return str;
}
