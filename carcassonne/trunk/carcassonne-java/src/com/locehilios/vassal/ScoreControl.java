package com.locehilios.vassal;

import VASSAL.build.AbstractConfigurable;
import VASSAL.build.Buildable;
import VASSAL.build.GameModule;
import VASSAL.build.module.Chatter;
import VASSAL.command.Command;
import VASSAL.tools.KeyStrokeListener;
import VASSAL.build.module.documentation.HelpFile;
import VASSAL.build.module.PlayerRoster;
import VASSAL.build.module.PrivateMap;
import VASSAL.build.module.Map;
import VASSAL.build.module.map.MovementReporter;
import VASSAL.build.module.map.boardPicker.board.RegionGrid;
import VASSAL.build.module.map.boardPicker.board.ZonedGrid;
import VASSAL.build.module.map.boardPicker.board.mapgrid.Zone;
import VASSAL.build.module.map.boardPicker.board.Region;
import VASSAL.build.module.map.boardPicker.Board;
import VASSAL.counters.Properties;
import VASSAL.counters.PieceCloner;
import VASSAL.counters.GamePiece;
import VASSAL.counters.Stack;
import VASSAL.counters.PropertiesPieceFilter;
import VASSAL.counters.PieceFilter;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.Point;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Vector;
import javax.swing.KeyStroke;

public class ScoreControl extends AbstractConfigurable {
  
/*
    // WHERE TO PUT THIS???
    // Possible way to center the table at the start?
    for (Enumeration e = (Enumeration) GameModule.getGameModule().getComponents(Map.class); e.hasMoreElements();) {
      //need to make sure this is the main map
      Map m = (Map) e.nextElement();
      m.centerAt(new Point(1550,1550));
    }
*/

  public static final String NAME = "Carcassonne Score Control";
  public static final int HIGHEST_REGION = 49;
  private Hashtable scoreMap = null;
 
  // constructor 
  public ScoreControl() {
    registerKeyStrokes();   
  }

  // print messages ONLY to the local chatter 
  private static void toPrivateChatter (String msg) {
    Command display = new Chatter.DisplayText(GameModule.getGameModule().getChatter(), "*** " + msg);
    display.execute();
  }
 
  // send message to everyone's chatter and the log
  private static void toChatter (String msg) {
    Command display = new Chatter.DisplayText(GameModule.getGameModule().getChatter(), "*** " + msg);
    display.execute();
    GameModule.getGameModule().sendAndLog(display);
  }

  // populate all of the possible point locations 
  private void loadScorePoints () {
    // sanity check
    if (scoreMap != null) {
      return;
    }
   
    // store the points in a hashtable 
    Hashtable h = new Hashtable();
   
    // loop over all the PrivateMaps (the score track will be on one)
    for (Enumeration pMaps = (Enumeration) GameModule.getGameModule().getComponents(PrivateMap.class); pMaps.hasMoreElements();) {
      // cast to Private Map
      PrivateMap map = (PrivateMap) pMaps.nextElement();
      
      // grab the board by these coords (i know it will be here
      Board b = map.findBoard(new Point(20,20));
      
      // only process if we found a board
      if (b != null) {
        try {
          // look for a ZonedGrid
          ZonedGrid zg = (ZonedGrid) b.getGrid();
          if (zg != null) {
            // loop over the Zones
            for (Iterator it = zg.getZones(); it.hasNext();) {
              Zone z = (Zone) it.next();
              if (z != null) {
                // for each zone look for a RegionGrid
                RegionGrid rg = (RegionGrid) z.getGrid();
                if (rg != null) {
                  // look for every region between 0 and HIGHEST_REGION
                  for (int i = 0; i <= HIGHEST_REGION; i++) {
                    Region r = myFindRegion(rg,""+i);
                    // put this location into our hashtable
                    h.put(""+i, r.getOrigin());
                  }
                }
              }
            }
          }
        }
        catch (Exception e) {
          // do nothing
        }
      }
    }
    
    // another sanity check 
    if (h.size() == HIGHEST_REGION+1) {
      this.scoreMap = h;
    }
  } 
 
  /*
   * register all the keystrokes i will listen for
   * currently this is CTRL - [0-9] for advancing the score
   * and CTRL - = for reporting the score
   */ 
  private void registerKeyStrokes() {
    // CTRL-[0-9]
    for (int i = 0; i < 10; i++) {
      GameModule.getGameModule().addKeyStrokeListener(new KeyStrokeListener(new myKeyListener(this,i),
      KeyStroke.getKeyStroke("control " + i)));
    }
    // = CTRL-key
    GameModule.getGameModule().addKeyStrokeListener(new KeyStrokeListener(new myKeyListener(this,50),
    KeyStroke.getKeyStroke("control EQUALS")));
  }

  /* 
   * display the current positions of the score meepls
   * automatically add in the score modifiers
   * this is only reported to the local chatter
   */
  public void displayScores () {
    // find all the score meeples (some may be out of play
    Vector sm = findAllScoreMeeples();
    
    // loop over the score meeples (printing their score)
    for (Enumeration e = sm.elements(); e.hasMoreElements();) {
      GamePiece s = (GamePiece) e.nextElement();
      
      // determine the score modifier (+50, +300, etc)
      String[] split = s.getName().split("\\+",2);
      int modifier = 0;
      if (split.length == 2) {
        modifier = Integer.parseInt(split[1]);
      }
      
      // determine the raw score (position on the board)
      int rawScore = Integer.parseInt(s.getMap().locationName(s.getPosition()));
     
      // report the sum to the local chatter 
      toPrivateChatter("    "+s.getProperty("owner")+": "+ (rawScore + modifier));
    }
  }

  // this is fired every time a score change is needed
  // increase is how much we want to go up, duh
  public void requestScoreChange(int increase) {
    // make sure we have an up-to-date score point map
    loadScorePoints();
    
    // transform 0 to 10 (giving us the ability to go up from 1 - 10)
    if (increase == 0) {
      increase = 10;
    }
    
    // locate this player's score meeple
    GamePiece myScoreMeeple = (GamePiece) findMyScoreMeeple();
    
    Command c = null;
   
    if (myScoreMeeple != null) {
      // find out where we are
      Point currentPoint = myScoreMeeple.getPosition();
      Map   currentMap   = myScoreMeeple.getMap();
      
      // determine what our score currently is
      int currentScore = Integer.parseInt(currentMap.locationName(currentPoint));
      
      // calculate the new score
      int newScore = currentScore + increase;
    
      // determine if we are rounding the corner 
      String newPos = "unknown"; 
      boolean increaseLevel = false;
      if (newScore > HIGHEST_REGION) {
        newPos = "" + (newScore - (HIGHEST_REGION + 1));
        increaseLevel = true;
      }
      else {
        newPos = "" + newScore;
      }
     
      // get the new location for the updated score 
      Point newPoint = (Point) scoreMap.get(newPos);
      
      if (newPoint != null) {
       
        // do the move 
        c = currentMap.placeOrMerge(myScoreMeeple,newPoint);
        MovementReporter mr = new MovementReporter(c);
        Command reportMove = mr.getReportCommand();
        reportMove.execute();
        c.append(reportMove);
      
        // if we rounded the corner, update the score modifier 
        if (increaseLevel) {
          // Save state prior to command (IMPORTANT TO DO)
          myScoreMeeple.setProperty(Properties.SNAPSHOT, PieceCloner.getInstance().clonePiece(myScoreMeeple));
          Command inc = myScoreMeeple.keyEvent( KeyStroke.getKeyStroke("control CLOSE_BRACKET") );
          c.append(inc);
        }
       
        // report all these changes 
        GameModule.getGameModule().sendAndLog(c);
        
        // because sometimes the new score modifier isn't visiblw
        myScoreMeeple.getMap().repaint();
      }
    }
    else {
      // This is when we can't find this player's score meeple.
      // for now, we do nothing
    }
  }

  // returns a vector of all score meeples (based on scoremeeple property)
  private Vector findAllScoreMeeples() {
    // filter to test if a GamePiece is a score meeple
    PieceFilter f = PropertiesPieceFilter.parse("scoremeeple = true");
    
    // vector to populate
    Vector gmList = new Vector();
    
    // look in all the PrivateMaps
    for (Enumeration pMaps = (Enumeration) GameModule.getGameModule().getComponents(PrivateMap.class); pMaps.hasMoreElements();) {
      PrivateMap map = (PrivateMap) pMaps.nextElement();
      
      // get an array of all pieces in that map
      GamePiece[] allMapPieces = map.getAllPieces();
      
      // loop over the pieces
      for (int i = 0; i < allMapPieces.length; i++) {
      
      if (f.accept(allMapPieces[i])) {
        // found one!
        gmList.add(allMapPieces[i]);
      }
      
        // If this wasn't it, check to see if this is a stack
        //   if it is, we'll look at the pieces in that
        if (allMapPieces[i] instanceof Stack) {
          Stack s = (Stack) allMapPieces[i];
          for (Enumeration se = s.getPieces(); se.hasMoreElements();) {
            GamePiece subPiece = (GamePiece) se.nextElement();
            if (f.accept(subPiece)) {
              // found one
              gmList.add(subPiece);
            }
          }
        }
      }
    }
    // here ya go
    return gmList;
  }

  // Locate the current player's score meeple
  private GamePiece findMyScoreMeeple () {
    // This filter is to test if a GamePiece is my score meeple
    PieceFilter f = PropertiesPieceFilter.parse("owner = " + PlayerRoster.getMySide() + " && scoremeeple = true");
    
    // Look in all the PrivateMaps
    for (Enumeration pMaps = (Enumeration) GameModule.getGameModule().getComponents(PrivateMap.class); pMaps.hasMoreElements();) {
      PrivateMap map = (PrivateMap) pMaps.nextElement();
      
      // Get an array of all pieces in that map
      GamePiece[] allMapPieces = map.getAllPieces();
      
      // Loop over the pieces
      for (int i = 0; i < allMapPieces.length; i++) {
      
      if (f.accept(allMapPieces[i])) {
        // Found it!
        return allMapPieces[i];
      }
      
        // If this wasn't it, check to see if this is a stack
        //   if it is, we'll look at the pieces in that
        if (allMapPieces[i] instanceof Stack) {
          Stack s = (Stack) allMapPieces[i];
          for (Enumeration se = s.getPieces(); se.hasMoreElements();) {
            GamePiece subPiece = (GamePiece) se.nextElement();
            if (f.accept(subPiece)) {
              // Found it!
              return subPiece;
            }
          }
        }
      }
    }
    // I don't know where it is
    return null;
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

  /*
   * Not sure of the right way to do this, but this works...
   * Create a ActionListener object for every distinct
   * keystroke I want to capture.  Then that ActionListener
   * notifies the ScoreControl that it's key was pressed.
   */ 
  public class myKeyListener implements ActionListener {
    private ScoreControl sc;
    private int number;
  
    public myKeyListener (ScoreControl sc, int number) {
      this.sc     = sc;
      this.number = number;
    }
    
    public void actionPerformed(ActionEvent a) {
      if (number == 50) {
        sc.displayScores();
      }
      else {
        sc.requestScoreChange(number);
      }
    }
  }

  // some code to find what region is known by name "name" in grid "grid"  
  public Region myFindRegion(RegionGrid grid,String name) {
     Region checkRegion;
     Region r = null;
     for (Enumeration e =  grid.getComponents(Region.class); e.hasMoreElements() && r==null;) {
       checkRegion = (Region) e.nextElement();
       if (checkRegion.getConfigureName().equals(name)) {
         r = checkRegion;
       }
     }
     return r;
   }    
}
