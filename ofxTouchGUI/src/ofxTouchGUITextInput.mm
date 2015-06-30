#include "ofxTouchGUITextInput.h"

// text input only works on ios atm

ofxTouchGUITextInput::ofxTouchGUITextInput(){

    keyboardSet = false;
    wasKeyboardOpen = false;
    //input = "";
    //placeHolderInput = "";
    //fontColor = ofColor(40,40,40,255);
    textColour = textColourDark;
    fontSize = 16;
    defaultInput = "";
    
    // DEFAULT TOGGLE BUTTON BACKGROUND CLRS: GRADIENT GRAY 75%
    // creates a fade from right to left instead of left to right
    bgClrTL = ofColor(255,255,255,255); //rgba
    bgClrTR = ofColor(255,255,255,255); //rgba
    bgClrBL = ofColor(255,255,255,255); //rgba
    bgClrBR = ofColor(255,255,255,255); //rgba
    
    #ifdef TARGET_OF_IPHONE
    #else
    isInteractive = true;
    #endif
}

ofxTouchGUITextInput::~ofxTouchGUITextInput(){
	
}

void ofxTouchGUITextInput::resetDefaultValue(){
    
    #ifdef TARGET_OF_IPHONE
        if(keyboardSet) {
            keyboard->setText(defaultInput);
        }
    #else
    *input = defaultInput;
    #endif
}

void ofxTouchGUITextInput::setInput(string *placeHolderText) {
    
    //placeHolderInput = placeHolderText;
    input = placeHolderText;
    
    #ifdef TARGET_OF_IPHONE
    
        if(!keyboardSet) {
            
            // setting up a keyboard with some basic defaults...
            keyboard = new ofxiPhoneKeyboard(posX, posY, width, height);
            
            //hide the keyboard far far away
            //keyboard = new ofxiPhoneKeyboardExtra(-5000, 0, 10, 10);
            keyboard->setVisible(true);
            //keyboard->setMaxChars(100);
            keyboard->setBgColor(255, 255, 255, 255); // retina weirdness if(retina)
            keyboard->setFontColor(textColour.r,textColour.g,textColour.b,textColour.a);
            keyboard->setFontSize(fontSize*2);
            //keyboard->disableAutoCorrection(); // disable auto type corrections, custom method added to ofxIphoneKeyboard.
            //keyboard->setPlaceholder(placeHolderText);
            //keyboard->setPosition(posX, posY);// + height);
            keyboard->updateOrientation();
            
            // register update events?
            //ofAddListener(ofEvents().update, this, &ofxTouchGUITextInput::updateKeyboard);
        }
        
        keyboard->setText(*input);
        //defaultInput = *placeHolderText;
        keyboardSet = true;
    
    #else
    
    #endif
    
}

void ofxTouchGUITextInput::setPlaceHolderText(string text) {
    
    #ifdef TARGET_OF_IPHONE
    keyboard->setText(text);
    #else
    *input = text;
    #endif
}

string ofxTouchGUITextInput::getInput() {
    return *input;
}

//ofEventArgs &e
void ofxTouchGUITextInput::updateKeyboard()
{
    #ifdef TARGET_OF_IPHONE
        *input = keyboard->getLabelText(); 
        
        if(keyboard->isKeyboardShowing()) {
            wasKeyboardOpen = true;
        } else {
            if(wasKeyboardOpen) {
                onKeyboardInput();
            }
            wasKeyboardOpen = false;
        }
    #endif
}


void ofxTouchGUITextInput::onKeyboardInput()
{    
    //input = keyboard->getLabelText(); 
    cout << "input: " << *input << endl;
    //ofNotifyEvent(onChangedEvent,*input,this);
    ofxTouchGUIEventArgs args(this);
    ofNotifyEvent(onChangedEvent, args);
    sendOSC(*input);
}

void ofxTouchGUITextInput::hide(){
    #ifdef TARGET_OF_IPHONE
        keyboard->setVisible(false);
    
    #endif
    ofxTouchGUIBase::hide();
}

void ofxTouchGUITextInput::show(bool activateSingleItem){
    #ifdef TARGET_OF_IPHONE
        keyboard->setVisible(true);
    #endif
    ofxTouchGUIBase::show(activateSingleItem);
}
    
//--------------------------------------------------------------
void ofxTouchGUITextInput::draw(){
    
    // not the best place to put this
    #ifdef TARGET_OF_IPHONE
        updateKeyboard();
    #else
    if(!hidden) {
        ofPushMatrix();
        ofTranslate(int(posX), int(posY));
        drawGLRect(vertexArr,colorsArr);//vertexArrActive, colorsArrActive);
        
        // draw text
        ofPushStyle();
        ofSetColor(textColourDark);
        //ofSetColor(textColourLight);
        //ofSetColor(textColour);

        // draw text
        drawText(*input, 0);
        
        ofPopStyle();
        ofPopMatrix();
    }
    #endif

     
}

//--------------------------------------------------------------
bool ofxTouchGUITextInput::onUp(float x, float y, int pId){
    
    //ofLog() << "on up!";
    if(ofxTouchGUIBase::onUp(x, y, pId)) {
        /*if(hitTest(x,y)) {
            
            doToggleAction(!*toggleVal);
            return true;
        }*/
        
        #ifdef TARGET_OF_IPHONE
        #else
        string userText = ofSystemTextBoxDialog("Enter text...");
        if(userText.length() > 0 && userText != *input) {
            *input = userText;
            onKeyboardInput();
        }
        
        // there is a bug with the mouse event after a dialog: https://github.com/openframeworks/openFrameworks/issues/2630
        //restoreAppWindowFocus();
        
        #endif
    }
    
    return false;
    
}


