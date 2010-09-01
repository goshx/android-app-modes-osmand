package net.osmand;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import net.osmand.data.MapObject;
import net.osmand.osm.LatLon;

import org.apache.commons.logging.Log;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteStatement;

public class BaseLocationIndexRepository<T extends MapObject> {
	private static final Log log = LogUtil.getLog(BaseLocationIndexRepository.class);
	protected SQLiteDatabase db;
	protected double dataTopLatitude;
	protected double dataBottomLatitude;
	protected double dataLeftLongitude;
	protected double dataRightLongitude;
	
	protected String name;
	
	protected List<T> cachedObjects = new ArrayList<T>(); 
	protected double cTopLatitude;
	protected double cBottomLatitude;
	protected double cLeftLongitude;
	protected double cRightLongitude;
	protected int cZoom;

	

	public synchronized void clearCache(){
		cachedObjects.clear();
		cTopLatitude = 0;
		cBottomLatitude = 0;
		cRightLongitude = 0;
		cLeftLongitude = 0;
		cZoom = 0;
	}
	
	public boolean initialize(final IProgress progress, File file, int version, String tableLocation) {
		long start = System.currentTimeMillis();
		if(db != null){
			// close previous db
			db.close();
		}
		db = SQLiteDatabase.openOrCreateDatabase(file, null);
		name = file.getName().substring(0, file.getName().indexOf('.'));
		if(db.getVersion() != version){
			db.close();
			db = null;
			return false;
		}
		String metaTable = "loc_meta_"+tableLocation; //$NON-NLS-1$
		Cursor cursor = db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='"+metaTable+"'", null); //$NON-NLS-1$ //$NON-NLS-2$
		boolean dbExist = cursor.moveToFirst();
		cursor.close();
		boolean found = false;
		boolean write = true;
		if(dbExist){
			cursor = db.rawQuery("SELECT MAX_LAT, MAX_LON, MIN_LAT, MIN_LON  FROM " +metaTable, null); //$NON-NLS-1$
			if(cursor.moveToFirst()){
				dataTopLatitude = cursor.getDouble(0);
				dataRightLongitude = cursor.getDouble(1);
				dataBottomLatitude = cursor.getDouble(2);
				dataLeftLongitude = cursor.getDouble(3);
				found = true;
			} else {
				found = false;
			}
			cursor.close();
		} else {
			try {
				db.execSQL("CREATE TABLE " + metaTable + " (MAX_LAT DOUBLE, MAX_LON DOUBLE, MIN_LAT DOUBLE, MIN_LON DOUBLE)"); //$NON-NLS-1$ //$NON-NLS-2$
			} catch (RuntimeException e) {
				// case when database is in readonly mode
				write = false;
			}
		}
		
		if (!found) {
			Cursor query = db.query(tableLocation,
					new String[] { "MAX(latitude)", "MAX(longitude)", "MIN(latitude)", "MIN(longitude)" }, null, null, null, null, null); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$
			if (query.moveToFirst()) {
				dataTopLatitude = query.getDouble(0) + 1;
				dataRightLongitude = query.getDouble(1) + 1.5;
				dataBottomLatitude = query.getDouble(2) - 1;
				dataLeftLongitude = query.getDouble(3) - 1.5;
			}
			query.close();
			if (write) {
				db.execSQL("INSERT INTO " + metaTable + " VALUES (?, ?, ? ,?)", new Double[]{dataTopLatitude, dataRightLongitude, dataBottomLatitude, dataLeftLongitude}); //$NON-NLS-1$ //$NON-NLS-2$
			}
		}
		if (log.isDebugEnabled()) {
			log.debug("Initializing db " + file.getAbsolutePath() + " " + (System.currentTimeMillis() - start) + "ms"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
		}
		return true;
	}
	
	public synchronized void close() {
		if (db != null) {
			db.close();
			dataRightLongitude = dataLeftLongitude = dataBottomLatitude = dataTopLatitude = 0;
			clearCache();
			db = null;
		}
	}
	
	public String getName() {
		return name;
	}
	
	protected void bindString(SQLiteStatement s, int i, String v){
		if(v == null){
			s.bindNull(i);
		} else {
			s.bindString(i, v);
		}
	}
	
	
	public boolean checkCachedObjects(double topLatitude, double leftLongitude, double bottomLatitude, double rightLongitude, int zoom, List<T> toFill){
		return checkCachedObjects(topLatitude, leftLongitude, bottomLatitude, rightLongitude, zoom, toFill, false);
	}
	
	public synchronized boolean checkCachedObjects(double topLatitude, double leftLongitude, double bottomLatitude, double rightLongitude, int zoom, List<T> toFill, boolean fillFound){
		if (db == null) {
			return true;
		}
		boolean inside = cTopLatitude >= topLatitude && cLeftLongitude <= leftLongitude && cRightLongitude >= rightLongitude
				&& cBottomLatitude <= bottomLatitude && cZoom == zoom;
		boolean noNeedToSearch = inside;
		if((inside || fillFound) && toFill != null){
			for(T a : cachedObjects){
				LatLon location = a.getLocation();
				if (location.getLatitude() <= topLatitude && location.getLongitude() >= leftLongitude && location.getLongitude() <= rightLongitude
						&& location.getLatitude() >= bottomLatitude) {
					toFill.add(a);
				}
			}
		}
		return noNeedToSearch;
	}

	public boolean checkContains(double latitude, double longitude){
		if(latitude < dataTopLatitude && latitude > dataBottomLatitude && longitude > dataLeftLongitude && longitude < dataRightLongitude){
			return true;
		}
		return false;
	}
	
	public boolean checkContains(double topLatitude, double leftLongitude, double bottomLatitude, double rightLongitude){
		if(rightLongitude < dataLeftLongitude || leftLongitude > dataRightLongitude){
			return false;
		}
		if(topLatitude < dataBottomLatitude || bottomLatitude > dataTopLatitude){
			return false;
		}
		return true;
	}
}
