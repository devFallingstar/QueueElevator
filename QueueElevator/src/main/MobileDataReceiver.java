package main;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class MobileDataReceiver extends Thread {

	private static ServerSocket mobileSock;
	private TopManager myTop;
	
	public MobileDataReceiver(TopManager _myTop) {
		myTop = _myTop;
	}

	public void waitingForReading() {

	}

	@Override
	public void run() {
		try {
			mobileSock = new ServerSocket(9999);
			while (true) {
				Socket sock = mobileSock.accept();
				System.out.println("ASDASD");

				new IndividualThread(sock).start();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	class IndividualThread extends Thread {
		Socket mySock;
		private BufferedReader in;
		private PrintWriter out;

		public IndividualThread(Socket _sock) {
			mySock = _sock;

			try {
				in = new BufferedReader(new InputStreamReader(mySock.getInputStream()));
				out = new PrintWriter(new OutputStreamWriter(mySock.getOutputStream()));
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		@Override
		public void run() {
			String msg = null;

			try {
				while (true) {
					msg = in.readLine();
					if (msg != null) {
						System.out.println(msg);
						String[] values = msg.split(":");
						int[] valuesInt = new int[3];
						int i = 0;
						
						for (String str : values){
							valuesInt[i] = Integer.parseInt(str);
							i++;
						}
						
						myTop.addReq(valuesInt[0], valuesInt[1], valuesInt[2]);
//						addReq(int dept, int arrive, int delay)
					}
				}

			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
					if (mySock != null) {
						mySock.close();
					}
				} catch (IOException e) {
					e.printStackTrace();
				}
				this.interrupt();
			}
		}
	}
}
