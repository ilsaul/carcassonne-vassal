package com.locehilios.vassal;

import VASSAL.build.AbstractConfigurable;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import VASSAL.build.Buildable;
import VASSAL.build.module.documentation.HelpFile;

public class ScoreControl extends AbstractConfigurable implements KeyListener {

  public static final String NAME = "Carcassonne Score Control";
  
  public ScoreControl() {
  }

  public void keyPressed(KeyEvent e) {
  }

  public void keyReleased(KeyEvent e) {
  }

  public void keyTyped(KeyEvent e) {
  }

  public static String getConfigureTypeName() {
    return NAME;
  }

  public String[] getAttributeDescriptions() {
    return new String[0];
}

  public Class[] getAttributeTypes() {
    return new Class[0];
  }

  public String[] getAttributeNames() {
    return new String[0];
  }

  public String getAttributeValueString(String key) {
    return "";
  }

  public void setAttribute(String key, Object value) {
  }

  public Class[] getAllowableConfigureComponents() {
    return new Class[0];
  }

  public HelpFile getHelpFile() {
    return HelpFile.getReferenceManualPage("ScoreControl.htm");
  }

  public void removeFrom(Buildable parent) {
  }

  public void addTo(Buildable parent) {
  }

}
